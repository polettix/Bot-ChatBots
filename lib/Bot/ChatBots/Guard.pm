package Bot::ChatBots::Guard;
use strict;
{ our $VERSION = '0.001006'; }

sub new { return bless {callback => $_[1]}, $_[0] }

sub release {
   my $self     = shift;
   my $callback = $self->callback();
   eval { $callback->() if $callback };
   $callback->(undef);
   return $self;
} ## end sub release

sub DESTROY { shift->release }

42;
