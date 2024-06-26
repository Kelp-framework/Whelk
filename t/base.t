use Kelp::Base -strict;
use Kelp::Test;
use Test::More;
use HTTP::Request::Common;
use Whelk;
use JSON::PP;

use lib 't/lib';

my $app = Whelk->new( mode => 'test' );
my $t = Kelp::Test->new( app => $app );

# JSON

$t->request( GET '/test' )
	->code_is(200)
	->json_cmp({success => JSON::PP::true, data => 'hello, world!'});

$t->request( GET '/test/t1' )
	->code_is(200)
	->json_cmp({success => JSON::PP::true, data => {id => 1337, name => 'elite'}});

$t->request( POST '/test/err' )
	->code_is(418)
	->json_cmp({success => JSON::PP::false, error => 'no can do'});

$t->request( GET '/test/err' )
	->code_is(404);

# YAML

$t->request( GET '/deep' )
	->code_is(200)
	->yaml_cmp({success => JSON::PP::true, data => 'hello, world!'});

$t->request( GET '/deep/err1' )
	->code_is(400)
	->content_type_is('text/plain')
	->content_is('400 - Bad Request');

$t->request( GET '/deep/err2' )
	->code_is(500)
	->yaml_cmp({success => JSON::PP::false, error => 'Internal error'});

done_testing;

