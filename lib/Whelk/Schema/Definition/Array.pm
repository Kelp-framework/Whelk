package Whelk::Schema::Definition::Array;

use Kelp::Base 'Whelk::Schema::Definition';

attr properties => undef;

sub _resolve
{
	my ($self) = @_;

	$self->properties($self->_build_nested($self->properties));
}

sub inhale
{
	my ($self, $value) = @_;

	if (ref $value eq 'ARRAY') {
		my $type = $self->properties;
		return undef unless $type;

		foreach my $index (keys @$value) {
			my $inhaled = $type->inhale($value->[$index]);
			return "array[$index]->$inhaled" if defined $inhaled;
		}

		return undef;
	}

	return 'array';
}

sub exhale
{
	my ($self, $value) = @_;

	my $type = $self->properties;
	return $value unless $type;

	@$value = map { $type->exhale($_) } @$value;
	return $value;
}

1;

