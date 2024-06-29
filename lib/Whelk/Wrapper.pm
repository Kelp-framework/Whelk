package Whelk::Wrapper;

use Kelp::Base;

use Try::Tiny;
use Scalar::Util qw(blessed);
use HTTP::Status qw(status_message);
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
	my $res = $app->res;

	# decide on the resulting code and data based on status
	if ($success) {
		my $code = $res->code || 200;
		$res->set_code($code);
		$success = int($code / 100) == 2;
	}
	else {
		if (blessed $data && $data->isa('Kelp::Exception')) {

			# Whelk exceptions are API exceptions and will yield API responses if
			# possible. Kelp exceptions are application exceptions and will yield a
			# regular error page.
			$data->throw unless $data->isa('Whelk::Exception');
			$res->set_code($data->code);
			$data = $data->body;
		}
		else {
			$res->set_code(500);
		}

		$data = $self->on_error($app, $data);
	}

	# set code and content type
	my $format = $app->response_format;
	$res->$format
		unless $res->content_type;

	# TODO: 204 no content
	my $response = $success ? $self->wrap_data($data) : $self->wrap_error($data);
	return $self->inhale_exhale($app, $endpoint, $response);
}

sub inhale_exhale
{
	my ($self, $app, $endpoint, $response, $inhale_error) = @_;
	my $schema = $self->map_code_to_schema($endpoint, $app->res->code);

	# try to inhale
	if ($app->whelk->inhale_response) {
		my $inhaled = $schema->inhale($response);
		if (defined $inhaled) {
			my $path = $endpoint->path;

			# if this is an error with inhaling itself, we have to resort to
			# throwing an exception to avoid an infinite recursion
			Kelp::Exception->throw(
				500,
				body => "could not inhale error response for $path: $inhaled"
			) if $inhale_error;

			# otherwise, we can inhale_exhale again, this time with an error
			$app->res->set_code(500);
			my $error = $self->on_error("response schema validation failed for $path: $inhaled");

			return $self->inhale_exhale($app, $endpoint, $self->wrap_error($error), 1);
		}
	}

	return $schema->exhale($response);
}

sub map_code_to_schema
{
	my ($self, $endpoint, $code) = @_;
	my $code_class = int($code / 100) * 100;
	return $endpoint->response_schemas->{$code_class};
}

sub on_error
{
	my ($self, $app, $data) = @_;

	$app->logger(error => $data)
		if $app->can('logger');

	return status_message($app->res->code);
}

sub wrap
{
	my ($self, $endpoint) = @_;
	$self->build_response_schemas($endpoint);

	return sub {
		my $app = shift;
		my $response = $self->prepare_response(
			$app,
			$endpoint,
			$self->execute($app, $endpoint, @_),
		);

		return $response;
	};
}

sub wrap_error
{
	my ($self, $error) = @_;

	...;
}

sub wrap_data
{
	my ($self, $data) = @_;

	...;
}

sub build_response_schemas
{
	my ($self, $endpoint) = @_;

	...;
}

1;

