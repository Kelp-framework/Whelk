package Whelk::Schema::Definition;

use Kelp::Base;
use Carp;
use Kelp::Util;
use Scalar::Util qw(blessed);
use Storable qw(dclone);

# no import loop, load Whelk::Schema for child classes
require Whelk::Schema;

attr properties => sub { {} };
attr required => !!1;

sub create
{
	my ($class, $args) = @_;

	return $class->_build($args);
}

sub new
{
	my $class = shift;
	my $self = $class->SUPER::new(@_);

	$self->_resolve;
	return $self;
}

sub _resolve { }

sub _build
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
		return $self->_build($type)->clone(@rest);
	}
	elsif (ref $item eq 'HASH') {
		my $type = delete $item->{type};
		croak 'no schema definition type specified'
			unless defined $type;

		my $class = __PACKAGE__;
		$type = ucfirst $type;

		return Kelp::Util::load_package("${class}::${type}")->new(%$item);
	}
	else {
		croak 'can only build a definition from SCALAR, ARRAY or HASH';
	}
}

sub clone
{
	my ($self, %more_data) = @_;
	my $class = ref $self;

	my $data = dclone({%{$self}});
	$data = Kelp::Util::merge($data, \%more_data, 1);
	return $class->new(%$data);

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

