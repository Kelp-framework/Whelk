package Whelk::Schema::Definition::Boolean;

use Kelp::Base 'Whelk::Schema::Definition::_Scalar';
use JSON::PP;
use List::Util qw(none);

sub inhale
{
	my ($self, $value) = @_;

	my $inhaled = $self->SUPER::inhale($value);
	return $inhaled if defined $inhaled;

	if (ref $value) {
		$inhaled = 'boolean'
			if none { $value eq $_ } (JSON::PP::true, JSON::PP::false);
	}
	else {
		$inhaled = 'boolean'
			if none { $value eq $_ } (1, 0, !!1, !!0);
	}

	return $inhaled;
}

sub exhale
{
	return pop() ? JSON::PP::true : JSON::PP::false;
}

1;

