package Kelp::Module::Whelk;

use Kelp::Base 'Kelp::Module';
use Kelp::Util;
use Carp;

attr openapi_generator => undef;
attr endpoints => sub { [] };

sub build {
	my ($self, %args) = @_;
	my $app = $self->app;

	# if this is Whelk or based on Whelk, use the main config
	if ($app->isa('Whelk')) {
		$args{$_} //= $app->config($_)
			for qw(api_resources openapi_endpoint);
	}

	# register before initializing, so that controllers have acces to whelk
	$self->register(whelk => $self);

	$self->_initialize_resources(%args);
	$self->_install_openapi(%args);
}

sub _initialize_resources {
	my ($self, %args) = @_;
	my $app = $self->app;

	my %resources = %{$args{api_resources} // {}};
	carp 'No api_resources for Whelk, you should define some in config'
		unless keys %resources;

	foreach my $resource (keys %resources) {
		my $controller = $app->context->controller($resource);
		croak "$resource does not extend " . $app->routes->base
			unless $controller->isa($app->routes->base);

		$controller->build($resources{$resource});
	}
}

sub _install_openapi {
	my ($self, %args) = @_;
	my $app = $self->app;

	my $endpoint = $args{openapi_endpoint};
	return unless $endpoint;

	croak 'openapi_endpoint requires path and format'
		unless $endpoint->{path} && $endpoint->{format};

	my $class = $endpoint->{class} // 'Whelk::OpenAPI';
	$self->openapi_generator(Kelp::Util::load_package($class)->new);

	$app->add_route([GET => $endpoint->{path}] => sub {
		my ($app) = @_;

		my $format = $endpoint->{format};
		$app->res->$format;
		return $self->generate_openapi;
	});
}

sub generate_openapi
{
	my ($self) = @_;

	return $self->openapi_generator->generate($self->endpoints);
}

1;

