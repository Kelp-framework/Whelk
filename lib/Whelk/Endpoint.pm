package Whelk::Endpoint;

use Kelp::Base;

attr -id => sub { $_[0]->route->has_name ? $_[0]->route->name : undef };
attr -route => sub { die 'route is required in endpoint' };
attr -code => sub { die 'code is required in endpoint' };
attr -path => \&_build_path;
attr -request_format => undef;
attr -request_schema => undef;
attr -response_format => sub { die 'response_format is required in endpoint' };
attr -response_schema => sub { die 'response_schema is required in endpoint' };
attr -parameters => sub { {} };

sub new
{
	my $class = shift;
	my $self = $class->SUPER::new(@_);

	$self->path;    # builds path
	return $self;
}

sub _build_path
{
	my ($self) = @_;
	my $pattern = $self->route->pattern;

	die 'only :normal placeholders are allowed in Whelk'
		if $pattern =~ m/[*>?]/;

	# Make path. First replace curlies with \0, same as in Kelp. Then adjust
	# parameters to OpenAPI format. Last remove \0
	my $path = $pattern;
	$path =~ s/[{}]/\0/g;

	while ($path =~ s/:(\w+)/{$1}/) {
		my $token = $1;

		# add path parameter
		$self->parameters->{path}{$token}{required} = 1;
	}

	$path =~ s/\0//g;

	return $path;
}

1;

