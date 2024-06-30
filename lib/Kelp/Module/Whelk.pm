package Kelp::Module::Whelk;

use Kelp::Base 'Kelp::Module';
use Kelp::Util;
use Carp;
use Whelk::Schema;

attr formatter => undef;
attr verbose => !!1;
attr inhale_response => !!1;
attr default_format => 'json';
attr openapi_generator => undef;
attr endpoints => sub { [] };

sub build
{
	my ($self, %args) = @_;
	$self->_load_config(\%args);

	# register before initializing, so that controllers have acces to whelk
	$self->register(whelk => $self);

	$self->_initialize_resources(%args);
	$self->_install_openapi(%args);
}

sub _load_config
{
	my ($self, $args) = @_;
	my $app = $self->app;

	$self->formatter(
		Kelp::Util::load_package($args->{formatter_class} // 'Whelk::Formatter')->new
	);

	$self->verbose($args->{verbose})
		if exists $args->{verbose};

	$self->inhale_response($args->{inhale_response})
		if exists $args->{inhale_response};

	# if this is Whelk or based on Whelk, use the main config
	if ($app->isa('Whelk')) {
		$args->{$_} //= $app->config("api_$_")
			for qw(
			resources
			openapi
			default_wrapper
			default_format
			);
	}

	$self->default_format($args->{default_format})
		if defined $args->{default_format};
}

sub _initialize_resources
{
	my ($self, %args) = @_;
	my $app = $self->app;

	$args{default_wrapper} //= 'Simple';
	my %resources = %{$args{resources} // {}};
	carp 'No resources for Whelk, you should define some in config'
		unless keys %resources;

	foreach my $resource (keys %resources) {
		my $controller = $app->context->controller($resource);
		my $config = $resources{$resource};

		$config = {
			path => $config
		} unless ref $config eq 'HASH';

		croak "$resource does not extend " . $app->routes->base
			unless $controller->isa($app->routes->base);

		croak "$resource does not implement Whelk::Role::Resource"
			unless $controller->DOES('Whelk::Role::Resource');

		croak "Wrong path for $resource"
			unless $config->{path} =~ m{^/};

		my $wrapper_class = $config->{wrapper} // $args{default_wrapper};
		$wrapper_class = Kelp::Util::camelize($wrapper_class, 'Whelk::Wrapper', 1);
		$controller->wrapper(Kelp::Util::load_package($wrapper_class)->new(resource => $controller));

		$controller->base_route($config->{path});
		$controller->build;
	}
}

sub _install_openapi
{
	my ($self, %args) = @_;
	my $app = $self->app;

	my $endpoint = $args{openapi};
	return unless $endpoint;

	croak 'openapi_path requires path and format'
		unless $endpoint->{path} && $endpoint->{format};

	my $class = $endpoint->{class} // 'Whelk::OpenAPI';
	$self->openapi_generator(Kelp::Util::load_package($class)->new);

	$self->openapi_generator->parse(
		paths => $self->endpoints,
		schemas => Whelk::Schema->all_schemas,
	);

	$app->add_route(
		[GET => $endpoint->{path}] => sub {
			my ($app) = @_;

			my $format = $endpoint->{format};
			$app->res->$format;
			return $self->generate_openapi;
		}
	);
}

sub generate_openapi
{
	my ($self) = @_;

	return $self->openapi_generator->generate;
}

1;

