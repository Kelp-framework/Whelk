package Whelk::Config;

use Kelp::Base 'Kelp::Module::Config';

attr data => sub {
	my $self = shift;
	return $self->merge(
		$self->SUPER::data,
		{
			default_format => 'json',

			modules      => [qw(Whelk JSON YAML)],
			modules_init => {
				Routes => {
					base => 'Whelk::Resource',
					rebless => 1,
					fatal => 1,
				},

				JSON => {
					utf8 => 0, # will not encode wide characters
				},

				YAML => {
					kelp_extensions => 1,
					boolean => 'JSON::PP,perl',
				},
			},
		}
	);
};

sub process_mode
{
	my ($self, $mode) = @_;

	return $self->SUPER::process_mode("whelk_$mode");
}

1;

