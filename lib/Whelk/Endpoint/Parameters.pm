package Whelk::Endpoint::Parameters;

use Kelp::Base;

use Carp;
use Whelk::Schema;

attr -path => sub { {} };
attr -query => sub { {} };
attr -header => sub { {} };
attr -cookie => sub { {} };

attr -path_schema => sub { $_[0]->build_schema($_[0]->path) };
attr -query_schema => sub { $_[0]->build_schema($_[0]->query, default => 1, array => 1) };
attr -header_schema => sub { $_[0]->build_schema($_[0]->header, array => 1) };
attr -cookie_schema => sub { $_[0]->build_schema($_[0]->cookie) };

sub build_schema
{
	my ($self, $hashref, %allow) = @_;
	return undef if !%$hashref;

	my $built = Whelk::Schema->build(
		{
			type => 'object',
			properties => $hashref,
		}
	);

	foreach my $key (keys %{$built->properties}) {
		my $item = $built->properties->{$key};
		my $is_scalar = $item->isa('Whelk::Schema::Definition::_Scalar');
		my $is_array = $item->isa('Whelk::Schema::Definition::Array');

		if ($is_array) {
			croak 'Whelk only supports array types in header and query parameters'
				unless $allow{array};
		}
		elsif (!$is_scalar) {
			croak 'Whelk only supports string, integer, number, boolean and array types in parameters';
		}

		croak 'Whelk only supports default values in query parameters'
			if $is_scalar && defined $item->default && !$allow{default};
	}

	return $built;
}

1;

