package Whelk::Resource::Test::Deep;

use Kelp::Base 'Whelk::Resource';

sub resource_format { 'yaml' }

sub build {
	my ($self, @args) = @_;
	$self->SUPER::build(@args);

	$self->add_endpoint('/' => {
		to => 'home',
	});

	$self->add_endpoint([GET => '/err1'] => {
		to => 'test#deep#error_action',
	});

	$self->add_endpoint([GET => '/err2'] => sub {
		die 'this could be a password dump';
	});
}

sub home {
	return 'hello, world!';
}

sub error_action {
	Kelp::Exception->throw(400);
}

1;

