package Whelk::Role::Resource;

use Kelp::Base -attr;
use Role::Tiny;

use Carp;

use Whelk::Endpoint;
use Whelk::Endpoint::Parameters;
use Whelk::Schema;

attr resource => undef;
attr base_route => undef;
attr wrapper => undef;
attr response_format => sub { shift->whelk->default_format };

sub _whelk_adjust_pattern
{
	my ($self, $pattern) = @_;

	# we don't handle regex
	croak 'Regex patterns are disallowed in Whelk'
		unless !ref $pattern;

	# glue up the route from base and used patterns
	$pattern = $self->base_route . $pattern;
	$pattern =~ s{/$}{};
	$pattern =~ s{/+}{/};

	return $pattern;
}

sub _whelk_adjust_to
{
	my ($self, $to) = @_;

	my $base = $self->routes->base;
	my $class = ref $self;
	if ($class !~ s/^${base}:://) {
		$class = "+$class";
	}

	if (!ref $to && $to !~ m{^\+|#|::}) {
		my $join = $class =~ m{#} ? '#' : '::';
		$to = join $join, $class, $to;
	}

	return $to;
}

sub request_body
{
	my ($self) = @_;

	# this is set by wrapper when there is request body validation
	return $self->stash->{request};
}

sub add_endpoint
{
	my ($self, $pattern, $args, %meta) = @_;

	# make sure we have hash (same as in Kelp)
	$args = {
		to => $args,
	} unless ref $args eq 'HASH';

	# handle [METHOD => $pattern]
	if (ref $pattern eq 'ARRAY') {
		$args->{method} = $pattern->[0];
		$pattern = $pattern->[1];
	}

	$pattern = $self->_whelk_adjust_pattern($pattern);
	$args->{to} = $self->_whelk_adjust_to($args->{to});
	$args->{method} //= 'GET';
	my $route = $self->add_route($pattern, $args)->parent;

	my $endpoint = Whelk::Endpoint->new(
		resource => $self->resource,
		route => $route,
		code => $route->dest->[1],
		request_formats => [values %{$self->whelk->formatter->supported_formats($self)}],
		response_format => $self->whelk->formatter->supported_format($self, $self->response_format),
		request_schema => Whelk::Schema->build_if_defined($meta{request}),
		response_schema => Whelk::Schema->build_if_defined($meta{response}),
		parameters => Whelk::Endpoint::Parameters->new(%{$meta{parameters} // {}}),
		summary => $meta{summary},
		description => $meta{description},
	);

	$endpoint->wrap($self);

	push @{$self->whelk->endpoints}, $endpoint;
	return $self;
}

after 'build' => sub {
	my ($self) = @_;

	$self->api;
};

sub api { }

1;

