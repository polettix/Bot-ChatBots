package Bot::ChatBots::Role::Sender;
use strict;
{ our $VERSION = '0.001011'; }

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

has start_loop => (
   is      => 'rw',
   default => sub { return 0 },
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

sub may_start_loop {
   my ($self, %args) = @_;
   my $start_loop =
     exists($args{start_loop})
     ? $args{start_loop}
     : $self->start_loop;
   Mojo::IOLoop->start if $start_loop && (!Mojo::IOLoop->is_running);
   return $self;
} ## end sub may_start_loop

sub ua_request {
   my ($self, $method, %args) = @_;
   $method = lc $method;

   my @ua_args = @{$args{ua_args}};

   my @callback =
       (scalar(@ua_args) && (ref($ua_args[-1] eq 'CODE'))) ? (pop @ua_args)
     : $self->has_callback ? ($self->callback)
     :                       ();

   my $res = $self->ua->$method(@ua_args, @callback);

   $self->may_start_loop(%args) if @callback;

   return $res;
} ## end sub ua_request

1;
