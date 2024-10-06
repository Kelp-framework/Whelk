package Whelk::Schema::ExtraRule;

use Whelk::StrictBase;
use Carp;

our @CARP_NOT = qw(Whelk::Schema);

attr '?openapi' => sub { {} };
attr '?hint' => sub { croak 'hint is required in rules' };
attr '?code' => sub {
	sub { }
};

sub inhale
{
	my ($self, $value) = @_;

	return $self->code->($value) ? undef : $self->hint;
}

1;

