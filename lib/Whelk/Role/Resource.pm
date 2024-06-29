package Whelk::Role::Resource;

use Kelp::Base -attr;
use Role::Tiny;

use Carp;

use Whelk::Endpoint;
use Whelk::Endpoint::Parameters;
use Whelk::Schema;

attr base_route => undef;
attr wrapper => undef;

attr response_format => sub { shift->whelk->default_format };
attr request_format => sub { shift->whelk->default_format };

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
		response_format => $self->response_format,
		request_schema => Whelk::Schema->build_if_defined($meta{request}),
		response_schema => Whelk::Schema->build_if_defined($meta{response}),
		parameters => Whelk::Endpoint::Parameters->new(%{$meta{parameters} // {}}),
	);

	$route->dest->[0] //= ref $self;    # make sure plain subs work
	$route->dest->[1] = $self->wrapper->wrap($endpoint);

	push @{$self->whelk->endpoints}, $endpoint;
	return $self;
}

after 'build' => sub {
	my ($self) = @_;

	$self->api;
};

sub api { }

1;

