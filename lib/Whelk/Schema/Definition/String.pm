package Whelk::Schema::Definition::String;

use Kelp::Base 'Whelk::Schema::Definition::Scalar';

sub inhale
{
	my ($self, $value) = @_;

	my $inhaled = $self->SUPER::inhale($value);
	return $inhaled if defined $inhaled;
	return 'string' if ref $value;
	return undef;
}

sub exhale
{
	return '' . pop();
}

1;

