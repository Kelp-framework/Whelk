package Whelk::Schema::Definition::Integer;

use Kelp::Base 'Whelk::Schema::Definition::Number';

sub inhale
{
	my ($self, $value) = @_;

	my $inhaled = $self->SUPER::inhale($value);
	return $inhaled if defined $inhaled;
	return 'integer' unless $value == int($value);
	return undef;
}

sub exhale
{
	return int(pop());
}

1;

