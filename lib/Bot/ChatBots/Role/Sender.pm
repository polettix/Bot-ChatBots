package Bot::ChatBots::Role::Sender;
use strict;
{ our $VERSION = '0.001010'; }

use Moo::Role;
requires 'send_message';

has callback => (
   is        => 'rw',
   lazy      => 1,
   predicate => 1,
   clearer   => 1,
);

has recipient => (
   is        => 'rw',
   lazy      => 1,
   predicate => 1,
   clearer   => 1,
);

has ua => (
   is      => 'rw',
   lazy    => 1,
   builder => 'BUILD_ua',
);

sub BUILD_ua {
   my $self = shift;
   require Mojo::UserAgent;
   return Mojo::UserAgent->new;
}

sub ua_request {
   my ($self, $method, @args) = @_;
   $method = lc $method;
   my @callback =
       (scalar(@args) && (ref($args[-1] eq 'CODE'))) ? (pop @args)
     : $self->has_callback ? ($self->callback)
     :                       ();
   my $res = $self->ua->$method(@args, @callback);
   Mojo::IOLoop->start
     if (!Mojo::IOLoop->is_running) && scalar(@callback);
   return $res;
} ## end sub ua_request

1;
