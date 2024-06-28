package Whelk::Role::Resource;

use Kelp::Base -attr;
use Role::Tiny;

use Carp;
use Try::Tiny;
use Scalar::Util qw(blessed);
use JSON::PP;

use Whelk::Schema;
use Whelk::Endpoint;
use Kelp::Exception;

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

sub execute_endpoint
{
	my ($self, $endpoint, @args) = @_;

	my ($success, $data);
	try {
		$data = $endpoint->code->($self, @args);
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
	my ($self, $endpoint, $success, $data) = @_;
	my $code;

	# set code
	if ($success) {
		$code = 200;
	}
	elsif (blessed $data && $data->isa('Whelk::Exception')) {
		$code = $data->code;
		$data = '' . $data->body;    # only strings in errors - try to stringify
	}
	elsif (blessed $data && $data->isa('Kelp::Exception')) {
		$data->throw;
	}
	else {
		$code = 500;
		$self->logger(error => $data)
			if $self->can('logger');
		$data = 'Internal error';
	}

	my $response = $self->wrap_response($success, $data);
	my $inhaled = $endpoint->response_schema->inhale($response);
	if (defined $inhaled) {
		my $path = $endpoint->path;
		Kelp::Exception->throw(
			500,
			body => "response schema validation failed for $path: $inhaled",
		);
	}

	# set code and content type
	$self->res->set_code($code);
	my $format = $self->response_format;
	$self->res->$format
		unless $self->res->content_type;

	return $response;
}

sub wrap_endpoint
{
	my ($self, $endpoint) = @_;

	return sub {
		my $self = shift;
		my $response = $self->prepare_response(
			$endpoint,
			$self->execute_endpoint($endpoint, @_),
		);

		return $endpoint->response_schema->exhale($response);
	};
}

sub wrap_response
{
	my ($self, $success, $data) = @_;

	return {
		success => $success,
		(
			$success
			? (data => $data)
			: (error => $data)
		),
	};
}

sub response_schema
{
	my ($self, $data_schema) = @_;

	return Whelk::Schema->build(
		type => 'object',
		properties => {
			success => {
				type => 'boolean',
			},
			data => [$data_schema, required => !!0],
			error => {
				type => 'string',
				required => !!0,
			},
		},
	);
}

sub add_endpoint
{
	my ($self, $pattern, $args, %meta) = @_;

	if (!$meta{response}) {
		carp 'no response schema, setting flat null'
			if $self->whelk->verbose;

		$meta{response} = {
			type => 'null',
		};
	}

	# make sure we have hash (same as in Kelp)
	$args = {
		to => $args,
	} unless ref $args eq 'HASH';

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

	if (!ref $args->{to} && $args->{to} !~ m{^\+|#|::}) {
		my $controller = $self->_controller;
		my $join = $controller =~ m{#} ? '#' : '::';
		$args->{to} = $controller . $join . $args->{to};
	}
	my $route = $self->add_route($pattern, $args)->parent;

	my $endpoint = Whelk::Endpoint->new(
		route => $route,
		code => $route->dest->[1],
		request_format => $self->request_format,
		request_schema => $meta{request},
		response_format => $self->response_format,
		response_schema => $self->response_schema($meta{response}),
		parameters => $meta{parameters},
	);

	$route->dest->[0] //= ref $self;    # make sure plain subs work
	$route->dest->[1] = $self->wrap_endpoint($endpoint);

	push @{$self->whelk->endpoints}, $endpoint;
	return $self;
}

sub api { }

before 'build' => sub {
	my ($self, $base_route) = @_;
	croak 'Wrong base route for ' . $self->_controller
		unless !ref $base_route && $base_route =~ m{^/};

	$self->base_route($base_route);
};

after 'build' => sub {
	my ($self) = @_;

	$self->api;
};

1;

