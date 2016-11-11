package Bot::ChatBots::Role::Sender;
use strict;
{ our $VERSION = '0.001015'; }

use Moo::Role;
requires 'send_message';

has recipient => (
   is        => 'rw',
   lazy      => 1,
   predicate => 1,
   clearer   => 1,
);

sub process {
   my ($self, $record) = @_;

   $record->{sent_message} = $self->send_message($record->{send_message})
     if (ref($record) eq 'HASH') && exists($record->{send_message});

   return $record;    # pass-through anyway
} ## end sub process

sub processor {
   my $self = shift;
   return sub { return $self->process(@_) };
}

1;
