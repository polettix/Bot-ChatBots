package Bot::ChatBots::Base;
use strict;
{ our $VERSION = '0.001'; }

use Log::Any ();

sub logger { return Log::Any->get_logger }

sub processor {
   my $self = shift;
   return sub { return $self->process(@_) };
}

42;
