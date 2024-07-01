package Whelk::Schema::Definition::Array;

use Kelp::Base 'Whelk::Schema::Definition';

attr properties => undef;
attr lax => !!0;

sub openapi_dump
{
	my ($self, $openapi_obj, %hints) = @_;

	my $res = {
		type => 'array',
		items => $self->properties->openapi_schema($openapi_obj),
	};

	if (defined $self->description) {
		$res->{description} = $self->description;
	}

	return $res;
}

sub _resolve
{
	my ($self) = @_;

	$self->properties($self->_build($self->properties))
		if $self->properties;
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
	elsif ($self->lax) {
		my $type = $self->properties;
		return undef unless $type;

		my $inhaled = $type->inhale($value);
		return "array[0]->$inhaled" if defined $inhaled;

		return undef;
	}

	return 'array';
}

sub exhale
{
	my ($self, $value) = @_;

	if (ref $value ne 'ARRAY' && $self->lax) {
		$value = [$value];
	}

	my $type = $self->properties;
	return $value unless $type;

	@$value = map { $type->exhale($_) } @$value;
	return $value;
}

1;

