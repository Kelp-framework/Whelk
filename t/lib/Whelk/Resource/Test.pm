package Whelk::Resource::Test;

use Kelp::Base 'Whelk::Resource';
use Whelk::Exception;

sub build
{
	my ($self, @args) = @_;
	$self->SUPER::build(@args);

	$self->add_endpoint(
		[GET => '/'] => {
			to => 'home',
		}
	);

	$self->add_endpoint(
		'/t1' => {
			to => 'Test::test_action',
		}
	);

	$self->add_endpoint(
		[POST => '/err'] => {
			to => 'test#error_action',
		}
	);
}

sub home
{
	return 'hello, world!';
}

sub test_action
{
	return {
		id => 1337,
		name => 'elite',
	};
}

sub error_action
{
	Whelk::Exception->throw(418, body => 'no can do');
}

1;

