package Whelk::Role::Resource;

use Kelp::Base -attr;
use Role::Tiny;

use Carp;
use Try::Tiny;
use Scalar::Util qw(blessed);
use JSON::PP;

attr base_route => undef;
attr response_format => sub { shift->config('default_format') };
attr request_format => undef;

sub _controller
{
	my $self = shift;
	my $base = $self->routes->base;
	my $class = ref $self;
	if ($class !~ s/^${base}:://) {
		$class = "+$class";
	}

	return $class;
}

sub _fill_path_parameters
{
	my ($self, $pattern, $parameters) = @_;

	croak 'only :normal placeholders are allowed in Whelk'
		if $pattern =~ m/[*>?]/;

	# Make path. First replace curlies with \0, same as in Kelp. Then adjust
	# parameters to OpenAPI format. Last remove \0
	my $path = $pattern;
	$path =~ s/[{}]/\0/g;

	while ($path =~ s/:(\w+)/{$1}/) {
		my $token = $1;

		# add path parameter
		$parameters->{path}{$token}{required} = 1;
	}

	$path =~ s/\0//g;

	return $path;
}

sub execute_endpoint
{
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

sub prepare_response
{
	my ($self, $success, $data) = @_;

	# set code
	if ($success) {
		$self->res->set_code(200);
	}
	elsif (blessed $data && $data->isa('Whelk::Exception')) {
		$self->res->set_code($data->code);
		$data = '' . $data->body;    # only strings in errors - try to stringify
	}
	elsif (blessed $data && $data->isa('Kelp::Exception')) {
		$data->throw;
	}
	else {
		$self->res->set_code(500);
		$self->logger(error => $data)
			if $self->can('logger');
		$data = 'Internal error';
	}

	# set content type
	my $format = $self->response_format;
	$self->res->$format
		unless $self->res->content_type;

	return ($success, $data);
}

sub wrap_endpoint
{
	my ($self, $endpoint) = @_;

	return sub {
		my $self = shift;
		my ($success, $data) = $self->prepare_response(
			$self->execute_endpoint($endpoint, @_)
		);

		return $self->wrap_response($success, $data);
	};
}

sub wrap_response
{
	my ($self, $success, $data) = @_;

	return {
		success => $success ? JSON::PP::true : JSON::PP::false,
		(
			$success
			? (data => $data)
			: (error => $data)
		),
	};
}

sub add_endpoint
{
	my ($self, $pattern, $args) = @_;

	# make sure we have hash (same as in Kelp)
	$args = {
		to => $args,
	} unless ref $args eq 'HASH';

	# extra Whelk data to get from the definition
	my $metadata = delete $args->{meta} // {};
	my $parameters = delete $args->{parameters} // {};

	# handle [METHOD => $pattern]
	if (ref $pattern eq 'ARRAY') {
		$args->{method} = $pattern->[0];
		$pattern = $pattern->[1];
	}

	# we don't handle regex
	croak 'Regex patterns are disallowed in Whelk'
		unless !ref $pattern;

	# glue up the route from base and used patterns
	$pattern = $self->base_route . $pattern;
	$pattern =~ s{/$}{};
	$pattern =~ s{/+}{/};

	my $path = $self->_fill_path_parameters($pattern, $parameters);

	if (!ref $args->{to} && $args->{to} !~ m{^\+|#|::}) {
		my $controller = $self->_controller;
		my $join = $controller =~ m{#} ? '#' : '::';
		$args->{to} = $controller . $join . $args->{to};
	}
	my $route = $self->add_route($pattern, $args)->parent;

	my $destination = $route->dest;
	$destination->[0] //= ref $self;    # make sure plain subs work
	$destination->[1] = $self->wrap_endpoint($destination->[1]);

	push @{$self->whelk->endpoints}, {
		id => $route->has_name ? $route->name : undef,
		path => $path,
		method => $route->method,
		format => {
			request => $self->request_format,
			response => $self->response_format,
		},
		parameters => $parameters,
		%{$metadata},
	};
}

sub api { }

before 'build' => sub {
	my ($self, $base_route) = @_;
	croak 'Wrong base route for ' . $self->_controller
		unless !ref $base_route && $base_route =~ m{^/.};

	$self->base_route($base_route);
};

after 'build' => sub {
	my ($self) = @_;

	$self->api;
};

1;

