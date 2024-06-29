package Whelk::Resource::Error;

use Kelp::Base 'Whelk::Resource';
use Whelk::Schema;
use Whelk::Exception;

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
		response => {
			name => \'test_response',
		},
	);

	$self->add_endpoint(
		[GET => '/no_string'] => sub {
			return {
				opt_num => 5,
			};
		},
		response => {
			name => \'test_response',
		},
	);

	$self->add_endpoint(
		[GET => '/not_a_number'] => sub {
			return {
				req_str => 42,
				opt_num => 'this got mixed up',
			};
		},
		response => {
			name => \'test_response',
		},
	);

	$self->add_endpoint(
		[GET => '/error_object'] => sub {
			Whelk::Exception->throw(
				403,
				body => {
					msg => 'wrong password',
				}
			);
		},
	);

	$self->add_endpoint(
		[GET => '/invalid_planned_error'] => sub {
			my ($self) = @_;
			$self->res->code(505);

			return {
				reason => 'not supported'
			};
		},
	);
}

1;

