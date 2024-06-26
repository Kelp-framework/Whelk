package Whelk::Role::Resource;

use Kelp::Base -attr;
use Role::Tiny;

use Carp;
use Try::Tiny;
use Scalar::Util qw(blessed);
use JSON::PP;

attr base_route => undef;

sub resource_format {
	my $self = shift;

	return $self->config('default_format');
}

sub _controller {
	my $self = shift;
	my $base = $self->routes->base;
	my $class = ref $self;
	$class =~ s/^${base}:://;

	return $class;
}

sub execute_endpoint {
	my ($self, $endpoint, @args) = @_;

	my ($success, $data);
	try {
		$data = $endpoint->($self, @args);
		$success = 1;
	}
	catch {
		$data = $_;
		$success = 0;
	};

	return ($success, $data);
}

sub prepare_response {
	my ($self, $success, $data) = @_;

	# set code
	if ($success) {
		$self->res->set_code(200);
	}
	elsif (blessed $data && $data->isa('Whelk::Exception')) {
		$self->res->set_code($data->code);
		$data = $data->body;
	}
	elsif (blessed $data && $data->isa('Kelp::Exception')) {
		die $data;
	}
	else {
		$self->res->set_code(500);
		$self->logger(error => $data)
			if $self->can('logger');
		$data = 'Internal error';
	}

	# set content type
	my $format = $self->resource_format;
	$self->res->$format
		unless $self->res->content_type;

	return ($success, $data);
}

sub wrap_endpoint {
	my ($self, $endpoint) = @_;

	return sub {
		my $self = shift;
		my ($success, $data) = $self->prepare_response(
			$self->execute_endpoint($endpoint, @_)
		);

		return $self->wrap_response($success, $data);
	};
}

sub wrap_response {
	my ($self, $success, $data) = @_;

	return {
		success => $success ? JSON::PP::true : JSON::PP::false,
		($success
			? (data => $data)
			: (error => $data)
		),
	};
}

sub add_endpoint {
	my ($self, $name, $args) = @_;

	$args = {
		to => $args,
	} unless ref $args eq 'HASH';

	if (ref $name eq 'ARRAY') {
		$args->{method} = $name->[0];
		$name = $name->[1];
	}

	croak 'Regex paths are disallowed in Whelk'
		unless !ref $name;

	$name = $self->base_route . $name;
	$name =~ s{/$}{};
	$name =~ s{/+}{/};

	if (!ref $args->{to} && $args->{to} !~ m{^\+|#|::}) {
		my $controller = $self->_controller;
		my $join = $controller =~ m{#} ? '#' : '::';
		$args->{to} =  $controller . $join . $args->{to};
	}
	my $route = $self->add_route($name, $args)->parent;

	my $destination = $route->dest;
	$destination->[0] //= ref $self; # make sure plain subs work
	$destination->[1] = $self->wrap_endpoint($destination->[1]);

	push @{$self->whelk->endpoints}, {
		path => $route->pattern,
		method => $route->method,
	};
}

before 'build' => sub {
	my ($self, $base_route) = @_;
	croak 'Wrong base route for ' . $self->_controller
		unless !ref $base_route && $base_route =~ m{^/.};

	$self->base_route($base_route);
};

1;

