package Whelk::Endpoint;

use Kelp::Base;
use Carp;
use Whelk::Schema;

attr -id => sub { $_[0]->route->has_name ? $_[0]->route->name : undef };
attr -route => sub { croak 'route is required in endpoint' };
attr -code => sub { croak 'code is required in endpoint' };
attr -path => \&_build_path;
attr -request_format => undef;
attr -request_schema => undef;
attr -response_format => sub { croak 'response_format is required in endpoint' };
attr -response_schema => sub { croak 'response_schema is required in endpoint' };
attr -parameters => sub { croak 'parameters are required in endpoint' };

# to be built in wrapers
attr -response_schemas => sub { {} };

sub new
{
	my $class = shift;
	my $self = $class->SUPER::new(@_);

	$self->path;    # builds path

	# build schemas to get any errors reported early
	$self->parameters->path_schema;
	$self->parameters->query_schema;
	$self->parameters->header_schema;
	$self->parameters->cookie_schema;

	return $self;
}

sub _build_path
{
	my ($self) = @_;
	my $pattern = $self->route->pattern;

	croak 'only :normal placeholders are allowed in Whelk'
		if $pattern =~ m/[*>?]/;

	# Make path. First replace curlies with \0, same as in Kelp. Then adjust
	# parameters to OpenAPI format. Lastly remove \0
	my $path = $pattern;
	$path =~ s/[{}]/\0/g;

	while ($path =~ s/:(\w+)/{$1}/) {
		my $token = $1;

		# add path parameter if not exists already and mark as required
		$self->parameters->path->{$token}{type} //= 'string';
		$self->parameters->path->{$token}{required} = !!1;
	}

	$path =~ s/\0//g;

	return $path;
}

1;

