use Kelp::Base -strict;
use Test::More;
use Whelk::Schema;
use JSON::PP;

use utf8;

################################################################################
# This tests inhaling of data into schemas
################################################################################

subtest 'should inhale null' => sub {
	my $schema = Whelk::Schema->build(
		type => 'null',
	);

	is $schema->inhale(undef), undef, 'inhaled undef ok';
	is $schema->inhale(''), 'null', 'inhaled empty string ok';
	is $schema->inhale(0), 'null', 'inhaled 0 ok';
};

subtest 'should inhale boolean' => sub {
	my $schema = Whelk::Schema->build(
		type => 'boolean',
	);

	is $schema->inhale(undef), 'defined', 'inhaled undef ok';
	is $schema->inhale(''), undef, 'inhaled empty string ok';
	is $schema->inhale(0), undef, 'inhaled 0 ok';
	is $schema->inhale(1), undef, 'inhaled 1 ok';
	is $schema->inhale([]), 'boolean', 'inhaled array ok';
	is $schema->inhale(JSON::PP::true), undef, 'inhaled true ok';
	is $schema->inhale(JSON::PP::false), undef, 'inhaled false ok';
};

subtest 'should inhale number' => sub {
	my $schema = Whelk::Schema->build(
		type => 'number',
	);

	is $schema->inhale(undef), 'defined', 'inhaled undef ok';
	is $schema->inhale(''), 'number', 'inhaled empty string ok';
	is $schema->inhale(0), undef, 'inhaled 0 ok';
	is $schema->inhale(0.2), undef, 'inhaled 0.2 ok';
	is $schema->inhale(1), undef, 'inhaled 1 ok';
	is $schema->inhale(-20.35), undef, 'inhaled -20.35 ok';
	is $schema->inhale('1E+3'), undef, 'inhaled 1E+3 string ok';
	is $schema->inhale('12.5'), undef, 'inhaled 12.5 string ok';
	is $schema->inhale('abc'), 'number', 'inhaled abc string ok';
	is $schema->inhale([]), 'number', 'inhaled array ok';
};

subtest 'should inhale integer' => sub {
	my $schema = Whelk::Schema->build(
		type => 'integer',
	);

	is $schema->inhale('abc'), 'number', 'inhaled abc string ok';
	is $schema->inhale(5), undef, 'inhaled 5 ok';
	is $schema->inhale(5.5), 'integer', 'inhaled 5.5 ok';
};

subtest 'should inhale string' => sub {
	my $schema = Whelk::Schema->build(
		type => 'string',
	);

	is $schema->inhale(''), undef, 'inhaled empty string ok';
	is $schema->inhale(5), undef, 'inhaled 5 ok';
	is $schema->inhale('zażółć gęslą jaźń'), undef, 'inhaled wide string ok';
	is $schema->inhale(undef), 'defined', 'inhaled undef ok';
	is $schema->inhale({}), 'string', 'inhaled hash ok';
};

subtest 'should inhale array' => sub {
	my $schema = Whelk::Schema->build(
		type => 'array',
		properties => {
			type => 'string',
		},
	);

	is $schema->inhale([]), undef, 'inhaled empty array ok';
	is $schema->inhale([undef]), 'array[0]->defined', 'inhaled undef ok';
	is $schema->inhale([undef, undef]), 'array[0]->defined', 'inhaled undef undef ok';
	is $schema->inhale(['str']), undef, 'inhaled string ok';
	is $schema->inhale(['str', undef]), 'array[1]->defined', 'inhaled string undef ok';
	is $schema->inhale(['str', {}]), 'array[1]->string', 'inhaled string hash ok';
	is $schema->inhale([qw(str1 str2 str3)]), undef, 'inhaled three strings ok';
};

subtest 'should inhale object' => sub {
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

	is $schema->inhale({}), 'object[bool]->defined', 'inhaled empty object ok';
	is $schema->inhale({bool => 0}), undef, 'inhaled bool ok';
	is $schema->inhale({int => -5}), 'object[bool]->defined', 'inhaled int ok';
	is $schema->inhale({bool => {}, int => -5}), 'object[bool]->boolean', 'inhaled bool int ok';
	is $schema->inhale({bool => JSON::PP::false, int => 5.5}), 'object[int]->integer', 'inhaled bool int 2 ok';
	is $schema->inhale({bool => 1, obj => {nested => 1}}), 'object[obj]->object[nested]->null',
		'inhaled bool obj 1 ok';
	is $schema->inhale({bool => 1, obj => {nested => undef}}), undef, 'inhaled bool obj undef ok';
};

done_testing;

