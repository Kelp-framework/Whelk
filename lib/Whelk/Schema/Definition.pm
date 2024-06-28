package Whelk::Schema::Definition;

use Kelp::Base;
use Carp;
use Kelp::Util;
use Scalar::Util qw(blessed);

# no import loop, load Whelk::Schema for child classes
require Whelk::Schema;

attr properties => sub { {} };
attr required => !!1;

sub create
{
	my ($class, $type, %args) = @_;

	my $type_class = "${class}::" . ucfirst $type;
	return Kelp::Util::load_package($type_class)->new(%args);
}

sub new
{
	my $class = shift;
	my $self = $class->SUPER::new(@_);

	$self->_resolve;
	return $self;
}

sub _resolve { }

sub _build_nested
{
	my ($self, $item) = @_;

	if (blessed $item && $item->isa(__PACKAGE__)) {
		return $item;
	}
	if (ref $item eq 'SCALAR') {
		return Whelk::Schema->get_by_name($$item);
	}
	elsif (ref $item eq 'ARRAY') {
		my ($type, @rest) = @$item;
		return $self->_build_nested($type)->clone(@rest);
	}
	else {
		return Whelk::Schema->build(%$item);
	}
}

sub clone
{
	my $self = shift;
	my $class = ref $self;

	return bless {%$self, @_}, $class;
}

sub exhale
{
	...;
}

sub inhale
{
	...;
}

1;

