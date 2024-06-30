package Whelk::Endpoint::Parameters;

use Kelp::Base;

use Carp;
use List::Util qw(any);
use Whelk::Schema;

attr -path => sub { {} };
attr -query => sub { {} };
attr -header => sub { {} };
attr -cookie => sub { {} };

attr -path_schema => sub { $_[0]->build_schema($_[0]->path) };
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

1;

