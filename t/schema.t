use Kelp::Base -strict;
use Test::More;
use Whelk::Schema;

################################################################################
# This tests creation and referencing of schemas
################################################################################

subtest 'should return undef if passed undef to build_if_defined' => sub {
	my $schema = Whelk::Schema->build_if_defined(undef);

	is $schema, undef, 'schema ok';
};

subtest 'should create a simple schema and reference it back' => sub {
	my $schema = Whelk::Schema->build(
		some_schema => {
			type => 'null',
		}
	);

	isa_ok $schema, 'Whelk::Schema::Definition::Null';

	my $ref_schema = Whelk::Schema->build(\'some_schema');

	is $schema, $ref_schema, 'schema referencing ok';
};

subtest 'should create a slightly complicated schema with references inside' => sub {
	my $ref_schema = Whelk::Schema->build(
		to_reference => {
			type => 'integer',
		}
	);

	my $schema = Whelk::Schema->build(
		{
			type => 'object',
			properties => {
				int => \'to_reference',
				bool => {
					type => 'boolean'
				},
			}
		}
	);

	isa_ok $schema, 'Whelk::Schema::Definition::Object';
	isa_ok $schema->properties->{int}, 'Whelk::Schema::Definition::Integer';
	is $schema->properties->{int}, $ref_schema, 'integer referenced ok';
	isa_ok $schema->properties->{bool}, 'Whelk::Schema::Definition::Boolean';
};

done_testing;

