package Whelk::Schema;

use Kelp::Base -strict;
use Whelk::Schema::Definition;
use Carp;

my %registered;

sub build_if_defined
{
	my ($class, $args) = @_;

	return undef unless defined $args;
	return $class->build($args);
}

sub build
{
	my ($class, @input) = @_;

	if (@input == 1) {
		croak 'usage: build($args)'
			unless ref $input[0];

		unshift @input, undef;
	}
	else {
		croak 'usage: build(name => $args)'
			unless @input == 2 && !ref $input[0] && ref $input[1];
	}

	my ($name, $args) = @input;
	my $self = Whelk::Schema::Definition->create($args);
	$self->name($name);

	croak "trying to reuse schema name " . $self->name
		if $self->name && $registered{$self->name};

	$registered{$self->name} = $self
		if $self->name;

	return $self;
}

sub get_or_build
{
	my ($class, $name, $args) = @_;

	return $registered{$name}
		if $registered{$name};

	return $class->build($name, $args);
}

sub get_by_name
{
	my ($class, $name) = @_;

	croak "no such referenced schema '$name'"
		unless $registered{$name};

	return $registered{$name};
}

sub all_schemas
{
	my ($class) = @_;

	return [values %registered];
}

1;

