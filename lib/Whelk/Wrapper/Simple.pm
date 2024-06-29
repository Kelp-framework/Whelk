package Whelk::Wrapper::Simple;

use Kelp::Base 'Whelk::Wrapper';
use Kelp::Exception;

sub wrap_error
{
	my ($self, $data) = @_;

	return {error => $data};
}

sub wrap_data
{
	my ($self, $data) = @_;

	return $data;
}

sub build_response_schemas
{
	my ($self, $endpoint) = @_;
	my $schema = $endpoint->response_schema;
	my $schemas = $endpoint->response_schemas;

	$schemas->{200} = $schema;

	$schemas->{500} = $schemas->{400} = Whelk::Schema->build(
		{
			type => 'object',
			properties => {
				error => {
					type => 'string',
				},
			},
		}
	);
}

1;

