package Whelk::Schema::Definition::String;

use Kelp::Base 'Whelk::Schema::Definition::_Scalar';

sub _inhale
{
	my ($self, $value) = @_;

	my $inhaled = $self->SUPER::_inhale($value);
	return $inhaled if defined $inhaled;
	return 'string' if ref $value;
	return undef;
}

sub _exhale
{
	return '' . pop();
}

1;

