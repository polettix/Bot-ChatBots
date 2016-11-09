package Bot::ChatBots::Role::WebHook;
use strict;
{ our $VERSION = '0.001010'; }

use Ouch;
use Mojo::URL;
use Log::Any qw< $log >;
use Scalar::Util qw< weaken >;
use Bot::ChatBots::Weak;
use Try::Tiny;

use Moo::Role;

requires 'normalize_record';
requires 'parse_request';

has app => (
   is => 'ro',
   lazy => 1,
   weak_ref => 1,
);

has custom_pairs => (
   is => 'rw',
   default => sub { return {} },
);

has method => (
   is => 'ro',
   lazy => 1,
);

has path => (
   is => 'ro',
   lazy => 1,
   builder => 'BUILD_path',
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

has url => (is => 'ro');

sub BUILD_method { return 'post' }

sub BUILD_path {
   my $self = shift;
   defined(my $url = $self->url)
     or ouch 500, 'undefined path and url for WebHook';
   return Mojo::URL->new($url)->path->to_string;
}

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

sub class_custom_pairs {
   my $self = shift;
   return %{$self->custom_pairs};
}

sub handler {
   my $self = shift;
   my $args = (@_ && ref($_[0])) ? $_[0] : {@_};

   my $source = {
      args  => $args,
      class => ref($self),
      refs  => Bot::ChatBots::Weak->new(
         self => $self,
         app  => $self->app,
      ),
      type  => $self->typename,
      $self->class_custom_pairs,
      %{$self->custom_pairs},
   };

   return sub {
      my $c = shift;
      $source->{refs}->set(c => $c);

      # whatever happens, the bot "cannot" fail or the platform will hammer
      # us with the same update over and over
      my @updates;
      try {
         @updates = $self->parse_request($c->req);
      }
      catch {
         $log->error(bleep $_);
      };

      my ($update, $outcome);
      my $n_updates = $#updates;
      for my $i (0 .. $n_updates) {
         $update = $updates[$i];
         try {
            my $record = $self->normalize_record(
               {
                  batch  => {
                     count => ($i + 1),
                     total => ($n_updates + 1),
                  },
                  source => $source,
                  stash  => $c->stash,
                  update => $update,
               }
            );
            $outcome = $self->process($record);
            1;
         } ## end try
         catch {
            $log->error(bleep $_);
         };
      }

      if (ref($outcome) eq 'HASH') {    # give the outcome a try
         return if $outcome->{rendered};
         if (defined(my $response = $outcome->{response})) {
            return $self->render_response($c, $response, $update)
              if $self->can('render_response');
         }
      } ## end if ($outcome)

      # this is the safe approach - everything went fine, nothing to say
      return $c->rendered(204);
   };
} ## end sub handler

sub install_route {
   my $self = shift;
   my $args = (@_ && ref($_[0])) ? $_[0] : {@_};
   my $method = lc($args->{method} // $self->method // 'post');
   my $r = $args->{routes} // $self->app->routes;
   my $p = $args->{path} // $self->path;
   return $r->$method($p => $self->handler($args));
}

sub process {
   my $self = shift;
   return $self->processor->(@_);
}

1;
