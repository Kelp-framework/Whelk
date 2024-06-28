package Whelk::Wrapper::WithStatus;

use Kelp::Base 'Whelk::Wrapper';

use Whelk::Schema;

sub wrap
{
	my ($self, $endpoint) = @_;
	$self->build_response_schema($endpoint);

	return $self->SUPER::wrap($endpoint);
}

sub wrap_data
{
	my ($self, $success, $data) = @_;

	return {
		success => !!$success,
		(
			$success
			? (data => $data)
			: (error => $data)
		),
	};
}

sub build_response_schema
{
	my ($self, $endpoint) = @_;
	my $schema = $endpoint->response_schema;

	my $full = Whelk::Schema->build(
		type => 'object',
		properties => {
			success => {
				type => 'boolean',
			},
			data => [$schema, required => !!0],
			error => {
				type => 'string',
				required => !!0,
			},
		},
	);

	$endpoint->full_response_schema($full);
}

1;

