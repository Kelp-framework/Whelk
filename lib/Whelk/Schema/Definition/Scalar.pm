package Whelk::Schema::Definition::Scalar;

use Kelp::Base 'Whelk::Schema::Definition';

sub inhale
{
	return 'defined' unless defined pop();
	return undef;
}

sub exhale
{
	return pop();
}

1;

