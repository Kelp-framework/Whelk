package Whelk::Schema::Definition::Array;

use Kelp::Base 'Whelk::Schema::Definition';

sub _resolve
{
	my ($self) = @_;

	my $item = $self->properties;
	if (ref $item eq 'SCALAR') {
		$item = Whelk::Schema->get_by_name($$item);
	}
	else {
		$item = Whelk::Schema->build(%$item);
	}

	$self->properties($item);
}

sub inhale
{
	my ($self, $value) = @_;

	if (ref $value eq 'ARRAY') {
		my $type = $self->properties;
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
	return [
		map { $type->exhale($_) } @$value
	];
}

1;

