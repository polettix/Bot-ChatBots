package WH;
use strict;

use Moo;
with 'Bot::ChatBots::Role::WebHook';
# requires 'normalize_record';
# requires 'pack_source';
# requires 'parse_request';
# requires 'process';

has _processed => (
   is => 'rw',
   default => sub { return [] },
);

sub normalize_record { return $_[1] }
sub pack_source { return {what => 'ever'} }
sub parse_request { return $_[1]->json }
sub process {
   my ($self, $record) = @_;
   push @{$self->_processed}, $record;
   return $record;
}

sub processed { return @{shift->_processed} }
sub reset { shift->_processed([]) }

1;
