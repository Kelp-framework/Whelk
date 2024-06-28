package Whelk::Wrapper::Simple;

use Kelp::Base 'Whelk::Wrapper';

sub wrap
{
	my ($self, $endpoint) = @_;
	$endpoint->full_response_schema($endpoint->response_schema);

	return $self->SUPER::wrap($endpoint);
}

sub wrap_data
{
	my ($self, $success, $data) = @_;

	return $data;
}

1;

