package Whelk::Wrapper;

use Kelp::Base;

use Try::Tiny;
use Scalar::Util qw(blessed);
use Kelp::Exception;
use Whelk::Exception;

sub execute
{
	my ($self, $app, $endpoint, @args) = @_;

	my ($success, $data);
	try {
		$data = $endpoint->code->($app, @args);
		$success = 1;
	}
	catch {
		$data = $_;
		$success = 0;
	};

	return ($success, $data);
}

sub prepare_response
{
	my ($self, $app, $endpoint, $success, $data) = @_;

	if ($success && $app->whelk->inhale_response) {
		my $inhaled = $endpoint->response_schema->inhale($data);
		if (defined $inhaled) {
			$success = !!0;
			my $path = $endpoint->path;
			$data = "response schema validation failed for $path: $inhaled";
		}
	}

	if ($success) {
		$app->res->set_code(200)
			unless $app->res->code;
	}
	elsif (blessed $data && $data->isa('Whelk::Exception')) {
		$app->res->set_code($data->code);
		$data = '' . $data->body;    # only strings in errors - try to stringify
	}
	elsif (blessed $data && $data->isa('Kelp::Exception')) {
		$data->throw;
	}
	else {
		$app->res->set_code(500);
		$app->logger(error => $data)
			if $app->can('logger');
		$data = 'Internal error';
	}

	my $response = $self->wrap_data($success, $data);

	# set code and content type
	my $format = $app->response_format;
	$app->res->$format
		unless $app->res->content_type;

	return $response;
}

sub wrap
{
	my ($self, $endpoint) = @_;

	return sub {
		my $app = shift;
		my $response = $self->prepare_response(
			$app,
			$endpoint,
			$self->execute($app, $endpoint, @_),
		);

		return $endpoint->full_response_schema->exhale($response);
	};
}

sub wrap_data
{
	my ($self, $success, $data) = @_;

	...;
}

1;

