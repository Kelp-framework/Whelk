use Kelp::Base -strict;
use Test::More;
use Test::Deep;
use Whelk::Schema;
use JSON::PP;

use utf8;

################################################################################
# This tests exhaling of data from variables based on schemas
################################################################################

subtest 'should exhale null' => sub {
	my $schema = Whelk::Schema->build(
		type => 'null',
	);

	is $schema->exhale(undef), undef, 'exhaled undef ok';
	is $schema->exhale(5), undef, 'exhaled 5 ok';
};

subtest 'should exhale boolean' => sub {
	my $schema = Whelk::Schema->build(
		type => 'boolean',
	);

	is $schema->exhale(1), JSON::PP::true, 'exhaled 1 ok';
	is $schema->exhale(0), JSON::PP::false, 'exhaled 0 ok';
	is $schema->exhale(JSON::PP::true), JSON::PP::true, 'exhaled json true ok';
	is $schema->exhale(JSON::PP::false), JSON::PP::false, 'exhaled json false ok';
};

subtest 'should exhale number' => sub {
	my $schema = Whelk::Schema->build(
		type => 'number',
	);

	is $schema->exhale(0), 0, 'exhaled 0 ok';
	is $schema->exhale('5'), 5, 'exhaled 5 string ok';
	is $schema->exhale('5.2'), 5.2, 'exhaled 5.2 string ok';
	is $schema->exhale(-0xff), -255, 'exhaled -0xff ok';
};

subtest 'should exhale integer' => sub {
	my $schema = Whelk::Schema->build(
		type => 'integer',
	);

	is $schema->exhale(9), 9, 'exhaled 9 ok';
	is $schema->exhale('9'), 9, 'exhaled 9 string ok';
	is $schema->exhale(4.9), 4, 'exhaled 4.9 ok';
};

subtest 'should exhale string' => sub {
	my $schema = Whelk::Schema->build(
		type => 'string',
	);

	is $schema->exhale(52), '52', 'exhaled 52 ok';
	is $schema->exhale(''), '', 'exhaled empty string ok';
	is $schema->exhale('zażółć gęslą jaźń'), 'zażółć gęslą jaźń', 'exhaled wide string ok';
};

subtest 'should exhale array' => sub {
	my $schema = Whelk::Schema->build(
		type => 'array',
		properties => {
			type => 'string',
		},
	);

	is_deeply $schema->exhale([]), [], 'exhaled empty array ok';
	is_deeply $schema->exhale([qw(abc def), 52]), [qw(abc def 52)], 'exhaled array ok';
};

subtest 'should exhale object' => sub {
	my $schema = Whelk::Schema->build(
		type => 'object',
		properties => {
			bool => {
				type => 'boolean',
			},
			int => {
				type => 'integer',
				required => !!0,
			},
			obj => {
				type => 'object',
				properties => {
					nested => {
						type => 'null',
					}
				},
				required => !!0,
			},
		},
	);

	is_deeply $schema->exhale({}), {}, 'exhaled empty object ok';
	is_deeply $schema->exhale({bool => 1}), {bool => JSON::PP::true}, 'exhaled bool ok';
	is_deeply $schema->exhale({bool => 1, obj => {nested => 5}}),
		{bool => JSON::PP::true, obj => {nested => undef}}, 'exhaled bool and obj ok';
};

done_testing;

