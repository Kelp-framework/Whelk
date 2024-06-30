package Whelk::Schema::Definition::Integer;

use Kelp::Base 'Whelk::Schema::Definition::Number';

sub _inhale
{
	my ($self, $value) = @_;

	my $inhaled = $self->SUPER::_inhale($value);
	return $inhaled if defined $inhaled;
	return 'integer' unless $value == int($value);
	return undef;
}

sub _exhale
{
	return int(pop());
}

1;

