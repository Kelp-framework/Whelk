package Whelk::Schema::Definition::Number;

use Kelp::Base 'Whelk::Schema::Definition::_Scalar';
use Scalar::Util qw(looks_like_number);

sub _inhale
{
	my ($self, $value) = @_;

	my $inhaled = $self->SUPER::_inhale($value);
	return $inhaled if defined $inhaled;
	return 'number' unless looks_like_number($value);
	return undef;
}

sub _exhale
{
	return 0 + pop();
}

1;

