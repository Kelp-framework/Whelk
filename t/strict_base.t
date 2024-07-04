use Kelp::Base -strict;
use Test::More;
use Test::Exception;
use Whelk::Schema;

################################################################################
# This tests whether the base for some whelk packages is strict
################################################################################

subtest 'schemas are strict' => sub {
	throws_ok {
		Whelk::Schema->build(
			test_int => {
				type => 'integer',
				minimum => 5, # not supported yet
			},
		);
	} qr{attribute minimum is not valid};

	throws_ok {
		Whelk::Schema->build(
			test_int => {
				type => 'array',
				properties => {
					type => 'boolean',
				}
			},
		);
	} qr{attribute properties is not valid};

	# extended attribute
	lives_ok {
		Whelk::Schema->build(
			test_int => {
				type => 'string',
				example => 'a string',
			},
		);
	};
};

done_testing;

