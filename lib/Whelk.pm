package Whelk;

use Kelp::Base 'Kelp';

attr 'config_module' => '+Whelk::Config';

sub before_dispatch { }

sub build
{
	my ($self) = @_;

	$self->whelk->init;
}

1;

__END__

=pod

=head1 NAME

Whelk - A friendly API framework based on Kelp

=head1 SYNOPSIS

	TODO

=head1 DESCRIPTION

TODO

