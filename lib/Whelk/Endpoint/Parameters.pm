package Whelk::Endpoint::Parameters;

use Kelp::Base;

use Carp;
use List::Util qw(any);
use Whelk::Schema;

attr -path => sub { {} };
attr -query => sub { {} };
attr -header => sub { {} };
attr -cookie => sub { {} };

# Path parameters are handled by Kelp, Whelk does not support schemas for it.
attr -query_schema => sub { $_[0]->build_schema($_[0]->query) };
attr -header_schema => sub { $_[0]->build_schema($_[0]->header) };
attr -cookie_schema => sub { $_[0]->build_schema($_[0]->cookie) };

sub build_schema
{
	my ($self, $hashref) = @_;
	return undef if !%$hashref;

	foreach my $key (keys %$hashref) {
		my $item = $hashref->{$key};

		croak 'Whelk only supports string, integer, number and boolean types in parameters'
			unless any { $item->{type} eq $_ } qw(string integer number boolean);
	}

	return Whelk::Schema->build(
		{
			type => 'object',
			properties => $hashref,
		}
	);
}

sub new
{
	my $class = shift;
	my $self = $class->SUPER::new(@_);

	# build schemas to get any errors reported early
	$self->query_schema;
	$self->header_schema;
	$self->cookie_schema;

	return $self;
}

1;

