use Kelp::Base -strict;
use Kelp::Test;
use Test::More;
use HTTP::Request::Common;
use Whelk;
use JSON::PP;

use lib 't/lib';

my $app = Whelk->new(mode => 'error');
my $t = Kelp::Test->new(app => $app);

################################################################################
# This tests if the API is correctly not passing data which is not in line with
# the defined request and response schemas.
################################################################################

$t->request(GET '/wrong_type')
	->code_is(500)
	->content_type_is('text/plain');

$t->request(GET '/no_string')
	->code_is(500)
	->content_type_is('text/plain');

$t->request(GET '/not_a_number')
	->code_is(500)
	->content_type_is('text/plain');

done_testing;

