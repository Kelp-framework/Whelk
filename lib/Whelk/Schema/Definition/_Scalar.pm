package Whelk::Schema::Definition::_Scalar;

use Kelp::Base 'Whelk::Schema::Definition';

attr required => sub { !defined $_[0]->default };
attr default => undef;

sub has_default
{
	return defined $_[0]->default;
}

sub _inhale
{
	return 'defined' unless defined pop();
	return undef;
}

sub inhale
{
	my ($self, $value) = @_;

	return $self->_inhale($value // $self->default);
}

sub _exhale
{
	return pop();
}

sub exhale
{
	my ($self, $value) = @_;

	return $self->_exhale($value // $self->default);
}

1;

