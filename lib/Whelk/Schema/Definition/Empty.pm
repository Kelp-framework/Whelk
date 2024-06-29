package Whelk::Schema::Definition::Empty;

use Kelp::Base 'Whelk::Schema::Definition';

sub inhale
{
	my ($self, $value) = @_;
	return 'empty' if defined $value && length $value;
	return undef;
}

sub exhale
{
	return '';
}

sub empty
{
	return !!1;
}

1;

