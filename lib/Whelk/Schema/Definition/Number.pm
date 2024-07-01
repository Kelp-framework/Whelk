package Whelk::Schema::Definition::Number;

use Kelp::Base 'Whelk::Schema::Definition::_Scalar';
use Scalar::Util qw(looks_like_number);

sub openapi_dump
{
	my ($self, $openapi_obj, %hints) = @_;

	my $res = {
		type => 'number',
	};

	if (defined $self->description) {
		$res->{description} = $self->description;
	}

	if (defined $self->default) {
		$res->{default} = $self->default;
	}

	if (defined $self->example) {
		$res->{example} = $self->example;
	}

	return $res;
}

sub _inhale
{
	my ($self, $value) = @_;

	my $inhaled = $self->SUPER::_inhale($value);
	return $inhaled if defined $inhaled;
	return 'number' unless looks_like_number($value);
	return undef;
}

sub _exhale
{
	return 0 + pop();
}

1;

