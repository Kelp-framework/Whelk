package Whelk::Schema::Definition::Number;

use Kelp::Base 'Whelk::Schema::Definition::_Scalar';
use Scalar::Util qw(looks_like_number);

sub inhale
{
	my ($self, $value) = @_;

	my $inhaled = $self->SUPER::inhale($value);
	return $inhaled if defined $inhaled;
	return 'number' unless looks_like_number($value);
	return undef;
}

sub exhale
{
	return 0 + pop();
}

1;

