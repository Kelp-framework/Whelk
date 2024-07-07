package Whelk::Endpoint;

use Whelk::StrictBase;
use Carp;
use Whelk::Schema;
use Whelk::Endpoint::Parameters;

attr '?-id' => sub { $_[0]->route->has_name ? $_[0]->route->name : undef };
attr '?-summary' => undef;
attr '?-description' => undef;
attr -resource => sub { croak 'resource is required in endpoint' };
attr -route => sub { croak 'route is required in endpoint' };
attr -formatter => sub { croak 'formatter is required in endpoint' };
attr -wrapper => sub { croak 'wrapper is required in endpoint' };
attr code => undef;
attr path => undef;
attr '?request' => undef;
attr '?response' => undef;
attr '?parameters' => undef;

# to be built in wrapers
attr -response_schemas => sub { {} };

sub new
{
	my $class = shift;
	my $self = $class->SUPER::new(@_);

	# build request and response schemas
	$self->request(Whelk::Schema->build_if_defined($self->request));
	$self->response(Whelk::Schema->build_if_defined($self->response));

	# initial build of the parameters
	$self->parameters(Whelk::Endpoint::Parameters->new(%{$self->parameters // {}}));

	# build path
	$self->path($self->_build_path);

	# build schemas to get any errors reported early
	$self->parameters->path_schema;
	$self->parameters->query_schema;
	$self->parameters->header_schema;
	$self->parameters->cookie_schema;

	# wrap the endpoint sub
	$self->code($self->route->dest->[1]);
	$self->route->dest->[1] = $self->wrapper->wrap($self);

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
		if (!$self->parameters->path->{$token}) {
			$self->parameters->path->{$token}{type} = 'string';
		}
	}

	$path =~ s/\0//g;

	return $path;
}

1;

