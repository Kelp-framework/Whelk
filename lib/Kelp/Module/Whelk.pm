package Kelp::Module::Whelk;

use Kelp::Base 'Kelp::Module';
use Kelp::Util;
use Carp;
use Whelk::Schema;
use Whelk::ResourceMeta;

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
		Kelp::Util::load_package($args->{formatter_class} // 'Whelk::Formatter')->new(
			app => $self->app,
		)
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

	# sort to have deterministic order of endpoints
	foreach my $resource (sort keys %resources) {
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

		$controller->resource(Whelk::ResourceMeta->new(class => $resource, config => $config));
		$controller->base_route($config->{path});
		$controller->api;
	}
}

sub _install_openapi
{
	my ($self, %args) = @_;
	my $app = $self->app;

	my $args = $args{openapi};
	return unless $args;

	croak 'openapi requires path'
		unless $args->{path};

	my $format = $args->{format} // $self->default_format;
	my $full_format = $self->formatter->supported_format($self->app, $format);
	my $class = $args->{class} // 'Whelk::OpenAPI';
	$self->openapi_generator(Kelp::Util::load_package($class)->new);

	$self->openapi_generator->parse(
		app => $app,
		info => $args->{info},
		endpoints => $self->endpoints,
		schemas => Whelk::Schema->all_schemas,
	);

	$app->add_route(
		[GET => $args->{path}] => sub {
			my ($app) = @_;

			$app->res->set_content_type($full_format, $app->res->charset // $app->charset);
			my $generated = $self->openapi_generator->generate();
			return $app->get_encoder($format => 'openapi')->encode($generated);
		}
	);
}

1;

