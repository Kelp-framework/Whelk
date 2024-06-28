package Whelk::Schema;

use Kelp::Base;
use Whelk::Schema::Definition;
use Carp;

attr -name => undef;
attr -definition => sub { die 'schema definition is required' };

my %registered;

sub build
{
	my ($class, @args) = @_;
	return undef if @args == 1 && !defined $args[0];
	my %args = @args == 1 && ref $args[0] eq 'HASH' ? %{$args[0]} : @args;

	my $name = delete $args{name};
	if (ref $name eq 'SCALAR') {
		return $class->get_by_name($$name);
	}

	my $type = delete $args{type};
	croak 'no schema definition type specified'
		unless defined $type;

	my $self = $class->SUPER::new(
		name => $name,
		definition => Whelk::Schema::Definition->create($type, %args)
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

