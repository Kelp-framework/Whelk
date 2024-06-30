package Whelk::Resource::Requests;

use Kelp::Base 'Whelk::Resource';
use Whelk::Exception;

sub api
{
	my ($self) = @_;

	$self->add_endpoint(
		[GET => '/path/:test1'] => sub {
			my ($self, @args) = @_;
			return @args == 1 && $args[0] eq '25';
		},
		response => {
			type => 'boolean',
		}
	);

	$self->add_endpoint(
		[GET => '/path/:test1/:test2'] => sub {
			my ($self, @args) = @_;
			return @args == 2 && $args[0] == 25 && $args[1];
		},
		parameters => {
			path => {
				test1 => {
					type => 'number',
				},
				test2 => {
					type => 'boolean',
				}
			},
		},
		response => {
			type => 'boolean',
		},
	);

	$self->add_endpoint(
		[GET => '/query'] => sub {
			my $self = shift;
			return $self->param('test1') == 25 && $self->param('test2');
		},
		parameters => {
			query => {
				test1 => {
					type => 'integer',
				},
				test2 => {
					type => 'boolean',
				},
			},
		},
		response => {
			type => 'boolean',
		},
	);

	$self->add_endpoint(
		[GET => '/header'] => sub {
			my $self = shift;
			return
				$self->req->header('X-test1') == 25
				&& $self->req->header('X-test2');
		},
		parameters => {
			header => {
				'X-Test1' => {
					type => 'integer',
				},
				'X-Test2' => {
					type => 'boolean',
				},
			},
		},
		response => {
			type => 'boolean',
		},
	);

	$self->add_endpoint(
		[GET => '/cookie'] => sub {
			my $self = shift;
			return
				$self->req->cookies->{'test1'} == 25
				&& $self->req->cookies->{'test2'};
		},
		parameters => {
			cookie => {
				'test1' => {
					type => 'integer',
				},
				'test2' => {
					type => 'boolean',
				},
			},
		},
		response => {
			type => 'boolean',
		},
	);

	$self->add_endpoint(
		[POST => '/body'] => sub {
			my $self = shift;
			my $method = $self->request_format . '_param';
			return $self->req->$method('test') == 25;
		},
		request => {
			type => 'object',
			properties => {
				test => {
					type => 'integer',
				},
			},
		},
		response => {
			type => 'boolean',
		},
	);
}

1;

