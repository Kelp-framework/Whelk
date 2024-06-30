package Whelk::Schema::Definition::Object;

use Kelp::Base 'Whelk::Schema::Definition';

attr properties => undef;
attr strict => !!0;

sub _resolve
{
	my ($self) = @_;

	my $properties = $self->properties;
	if ($properties) {
		foreach my $key (keys %{$properties}) {
			$properties->{$key} = $self->_build($properties->{$key});
		}
	}
}

sub inhale
{
	my ($self, $value) = @_;

	if (ref $value eq 'HASH') {
		my $properties = $self->properties;
		return undef unless $properties;

		foreach my $key (keys %$properties) {
			if (!exists $value->{$key}) {
				return "object[$key]->required"
					if $properties->{$key}->required;

				next;
			}

			my $inhaled = $properties->{$key}->inhale($value->{$key});
			return "object[$key]->$inhaled" if defined $inhaled;
		}

		if ($self->strict && keys %$value > keys %$properties) {
			foreach my $key (keys %$value) {
				next if exists $properties->{$key};
				return "object[$key]->redundant";
			}
		}

		return undef;
	}

	return 'object';
}

sub exhale
{
	my ($self, $value) = @_;

	my $properties = $self->properties;
	return $value unless $properties;

	foreach my $key (keys %$properties) {
		next if !exists $value->{$key} && !$properties->{$key}->has_default;

		$value->{$key} = $properties->{$key}->exhale($value->{$key});
	}

	return $value;
}

1;

