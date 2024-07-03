package Whelk::Resource::Manual;

use Kelp::Base 'Whelk::Resource';
use Whelk::Schema;

sub api
{
	my ($self) = @_;

	Whelk::Schema->build(
		my_num => {
			type => 'number',
		}
	);

	# extend my_num schema to add default
	Whelk::Schema->build(
		my_num_optional => [
			\'my_num',
			default => 1,
		]
	);

	$self->add_endpoint(
		'/multiply/:number' => {
			name => 'multiply',
			method => 'POST',
			to => sub {
				my ($self, $number) = @_;

				$number = $number
					* ($self->req->header('X-Number') // 1)
					* ($self->req->cookies->{number} // 1)
					* $self->req->query_param('number')
					* $self->request_body->{number};

				return {number => $number};
			},
		},
		parameters => {
			path => {
				number => \'my_num',
			},
			header => {
				'X-Number' => \'my_num_optional',
			},
			cookie => {
				number => \'my_num_optional',
			},
			query => {
				number => \'my_num_optional'
			},
		},
		request => {
			type => 'object',
			properties => {
				number => \'my_num_optional',
			}
		},
		response => {
			type => 'object',
			properties => {
				number => \'my_num'
			}
		}
	);
}

1;

