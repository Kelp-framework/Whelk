package Whelk::Resource::Error;

use Kelp::Base 'Whelk::Resource';
use Whelk::Schema;

sub api
{
	my ($self) = @_;

	Whelk::Schema->build(
		name => 'test_response',
		type => 'object',
		properties => {
			opt_num => {
				type => 'number',
				required => !!0,
			},
			req_str => {
				type => 'string',
			},
		},
	);

	$self->add_endpoint(
		[GET => '/wrong_type'] => sub {
			return [11];
		},
		response => \'test_response',
	);

	$self->add_endpoint(
		[GET => '/no_string'] => sub {
			return {
				opt_num => 5,
			};
		},
		response => \'test_response',
	);

	$self->add_endpoint(
		[GET => '/not_a_number'] => sub {
			return {
				req_str => 42,
				opt_num => 'this got mixed up',
			};
		},
		response => \'test_response',
	);
}

1;

