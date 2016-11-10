package WH2;
use strict;

use Moo;
with 'Bot::ChatBots::Role::WebHook';

# requires 'normalize_record';
sub normalize_record { }

# requires 'pack_source';
sub pack_source { }

# requires 'parse_request';
sub parse_request { }

# requires 'process';
# THIS IS NOT IMPLEMENTED ON PURPOSE, TO TRIGGER AN ERROR IN TESTS
# sub process { }

1;
