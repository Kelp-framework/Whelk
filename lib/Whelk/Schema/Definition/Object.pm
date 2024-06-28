package Whelk::Schema::Definition::Object;

use Kelp::Base 'Whelk::Schema::Definition';

sub _resolve
{
	my ($self) = @_;

	my $properties = $self->properties;
	foreach my $key (keys %{$properties}) {
		$properties->{$key} = $self->_build_nested($properties->{$key});
	}
}

sub inhale
{
	my ($self, $value) = @_;

	if (ref $value eq 'HASH') {
		my $properties = $self->properties;
		foreach my $key (keys %$properties) {
			next if !exists $value->{$key} && !$properties->{$key}->required;

			my $inhaled = $properties->{$key}->inhale($value->{$key});
			return "object[$key]->$inhaled" if defined $inhaled;
		}

		return undef;
	}

	return 'object';
}

sub exhale
{
	my ($self, $value) = @_;

	my %result;
	my $properties = $self->properties;
	foreach my $key (keys %$properties) {
		next if !exists $value->{$key};

		$result{$key} = $properties->{$key}->exhale($value->{$key});
	}

	return \%result;
}

1;

