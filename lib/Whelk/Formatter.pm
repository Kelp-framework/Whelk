package Whelk::Formatter;

use Kelp::Base;
use Whelk::Exception;

sub supported_formats
{
	return {
		json => 'application/json',
		yaml => 'text/yaml',
	};
}

sub match_format
{
	my ($self, $app) = @_;
	my $formats = $self->supported_formats;

	foreach my $format (keys %$formats) {
		return $format
			if $app->req->content_type_is($formats->{$format});
	}

	Whelk::Exception->throw(400, hint => "Unsupported Content-Type");
}

sub get_request_body
{
	my ($self, $app) = @_;
	my $format = $self->match_format($app);

	return
		$format eq 'json' ? $app->req->json_content :
		$format eq 'yaml' ? $app->req->yaml_content :
		undef;
}

1;

