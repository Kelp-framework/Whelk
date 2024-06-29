package Whelk::Schema;

use Kelp::Base;
use Whelk::Schema::Definition;
use Carp;

attr -name => undef;
attr -definition => sub { die 'schema definition is required' };

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

	my $self = $class->SUPER::new(
		name => $name,
		definition => Whelk::Schema::Definition->create($args)
	);

	croak "trying to reuse schema name $name"
		if $self->name && $registered{$self->name};

	$registered{$self->name} = $self
		if $self->name;

	return $self->definition;
}

sub get_by_name
{
	my ($class, $name) = @_;

	croak "no such referenced schema '$name'"
		unless $registered{$name};

	return $registered{$name}->definition;
}

sub all_schemas
{
	my ($class) = @_;

	return [map { $registered{$_} } sort keys %registered];
}

1;

