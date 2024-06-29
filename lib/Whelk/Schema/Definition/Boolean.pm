package Whelk::Schema::Definition::Boolean;

use Kelp::Base 'Whelk::Schema::Definition::_Scalar';
use JSON::PP;
use List::Util qw(any);

sub inhale
{
	my ($self, $value) = @_;

	my $inhaled = $self->SUPER::inhale($value);
	return $inhaled if defined $inhaled;

	$inhaled = 'boolean'
		unless any { $value eq $_ } (
			1,
			0,
			!!1,
			!!0,
			JSON::PP::true,
			JSON::PP::false,
		);

	return $inhaled;
}

sub exhale
{
	return pop() ? JSON::PP::true : JSON::PP::false;
}

1;

