package Whelk::Schema::Definition::Null;

use Kelp::Base 'Whelk::Schema::Definition';

sub inhale
{
	return 'null' unless !defined pop();
	return undef;
}

sub exhale
{
	return undef;
}

1;

