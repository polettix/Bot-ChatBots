package Bot::ChatBots::Auth;
use strict;
{ our $VERSION = '0.001010'; }

use Mo qw< default >;
extends 'Bot::ChatBots::Base';

has channels => (default => sub { return {} });
has name => (default => sub { return ref($_[0]) || $_[0] });
has users => (default => sub { return {} });

sub process {
   my ($self, $record) = @_;
   my $name = $self->name;
   my $logger = $self->logger;

   my $users = $self->users;
   if (keys %$users) {
      my $id = $record->{sender}{id} // return;
      if (exists $users->{blacklist}{$id}) {
         $logger->info("$name: sender '$id' is blacklisted, blocking");
         return;
      }
      if (scalar(keys %{$users->{whitelist}})
         && (!exists($users->{whitelist}{$id})))
      {
         $logger->info("$name: sender '$id' not whitelisted, blocking");
         return;
      } ## end if (scalar(keys %{$users...}))
   } ## end if (keys %$users)

   my $channels = $self->channels;
   if (keys %$channels) {
      my $id = $record->{channel}{fqid} // $record->{channel}{id}
        // return;
      if (exists $channels->{blacklist}{$id}) {
         $logger->info("$name: chat '$id' is blacklisted, blocking");
         return;
      }
      if (scalar(keys %{$channels->{whitelist}})
         && (!exists($channels->{whitelist}{$id})))
      {
         $logger->info("$name: chat '$id' not whitelisted, blocking");
         return;
      } ## end if (scalar(keys %{$channels...}))
   } ## end if (keys %$channels)

   $logger->info("$name: no reason to block, allowing");
   return $record;
} ## end sub authenticate

42;
