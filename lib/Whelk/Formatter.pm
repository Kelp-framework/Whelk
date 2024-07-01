package Whelk::Formatter;

use Kelp::Base;
use Carp;
use Whelk::Exception;

sub supported_format
{
	my ($self, $app, $format) = @_;
	my $formats = $self->supported_formats($app);

	croak "Format $format is not supported"
		unless exists $formats->{$format};

	return $formats->{$format};
}

sub supported_formats
{
	my ($self, $app) = @_;
	my $app_encoders = $app->encoder_modules;
	my %supported = (
		json => 'application/json',
		yaml => 'text/yaml',
	);

	foreach my $encoder (keys %supported) {
		delete $supported{$encoder}
			if !exists $app_encoders->{$encoder};
	}

	return \%supported;
}

sub match_format
{
	my ($self, $app) = @_;
	my $formats = $self->supported_formats($app);

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

