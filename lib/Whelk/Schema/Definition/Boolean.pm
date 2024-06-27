package Whelk::Schema::Definition::Boolean;

use Kelp::Base 'Whelk::Schema::Definition::Scalar';
use JSON::PP;

sub inhale
{
	my ($self, $value) = @_;

	my $inhaled = $self->SUPER::inhale($value);
	return $inhaled if defined $inhaled;

	if (ref $value) {
		$inhaled = 'boolean' if $value != JSON::PP::true && $value != JSON::PP::false;
	}

	return $inhaled;
}

sub exhale
{
	return pop() ? JSON::PP::true : JSON::PP::false;
}

1;

