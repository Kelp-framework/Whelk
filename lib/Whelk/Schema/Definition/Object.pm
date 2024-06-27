package Whelk::Schema::Definition::Object;

use Kelp::Base 'Whelk::Schema::Definition';

sub _resolve
{
	my ($self) = @_;

	my $properties = $self->properties;
	foreach my $key (keys %{$properties}) {
		if (ref $properties->{$key} eq 'SCALAR') {
			$properties->{$key} = Whelk::Schema->get_by_name(${$properties->{$key}});
		}
		else {
			$properties->{$key} = Whelk::Schema->build(%{$properties->{$key}});
		}
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

