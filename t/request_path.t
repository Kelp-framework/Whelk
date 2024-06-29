use Kelp::Base -strict;
use Kelp::Test;
use Test::More;
use HTTP::Request::Common;
use Whelk;
use JSON::PP;

use lib 't/lib';

my $app = Whelk->new(mode => 'requests');
my $t = Kelp::Test->new(app => $app);

################################################################################
# This test is a placeholder for possible future path validation to be built
# into Whelk. Currently, paths are handled at Kelp level and will return
# text/plain 404 when not matched.
################################################################################

$t->request(GET '/path')
	->code_is(404)
	->content_type_is('text/plain');

$t->request(GET '/path/2')
	->code_is(404)
	->content_type_is('text/plain');

$t->request(GET '/path/2/5')
	->code_is(200)
	->json_cmp(JSON::PP::true);

$t->request(GET '/path/1/6')
	->code_is(200)
	->json_cmp(JSON::PP::false);

done_testing;

