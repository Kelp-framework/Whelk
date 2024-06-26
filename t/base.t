use Kelp::Base -strict;
use Kelp::Test;
use Test::More;
use HTTP::Request::Common;
use Whelk;
use JSON::PP;

use lib 't/lib';

my $app = Whelk->new(mode => 'base');
my $t = Kelp::Test->new(app => $app);

################################################################################
# This tests a very basic JSON resource created manually thorugh add_endpoint
# calls
################################################################################

$t->request(GET '/test')
	->code_is(200)
	->json_cmp({success => JSON::PP::true, data => 'hello, world!'});

$t->request(GET '/test/t1')
	->code_is(200)
	->json_cmp({success => JSON::PP::true, data => {id => 1337, name => 'elite'}});

$t->request(POST '/test/err')
	->code_is(418)
	->json_cmp({success => JSON::PP::false, error => 'no can do'});

$t->request(GET '/test/err')
	->code_is(404);

done_testing;

