package Whelk::Exception;

use Kelp::Base 'Kelp::Exception';

# hint (string) to send to the user. App won't create a log if hint is present.
attr -hint => undef;

1;

