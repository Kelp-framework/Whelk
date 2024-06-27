package Whelk::Schema::Definition;

use Kelp::Base;
use Carp;
use Kelp::Util;

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

sub exhale
{
	...;
}

sub inhale
{
	...;
}

1;

