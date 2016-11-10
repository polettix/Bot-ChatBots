package Bot::ChatBots::Role::Source;
use strict;
{ our $VERSION = '0.001012'; }

use Ouch;
use Bot::ChatBots::Weak;

use Moo::Role;

has custom_pairs => (
   is => 'rw',
   default => sub { return {} },
);

has processor => (
   is => 'ro',
   lazy => 1,
   builder => 'BUILD_processor',
);

has typename => (
   is => 'ro',
   lazy => 1,
   builder => 'BUILD_typename',
);

sub BUILD_processor {
   ouch 500, 'no processor defined!';
}

sub BUILD_typename {
   my $self = shift;
   my @chunks = split /::/, lc ref $self;
   return (
      ((@chunks == 1) || ($chunks[-1] ne 'webhook')) ? $chunks[-1]
      :                                                $chunks[-2]
   );
}

sub pack_source {
   my $self = shift;
   my $args = (@_ && ref($_[0])) ? $_[0] : {@_};

   my %class_custom_pairs = $self->can('class_custom_pairs')
     ? $self->class_custom_pairs
     : ();
   my $source = {
      args  => $args,
      class => ref($self),
      refs  => Bot::ChatBots::Weak->new(
         self => $self,
      ),
      type  => $self->typename,
      %class_custom_pairs,
      %{$self->custom_pairs},
   };
   $source->{refs}->set(app => $self->app) if $self->can('app');

   return $source;
}

sub process {
   my $self = shift;
   return $self->processor->(@_);
}

1;
