package Bot::ChatBots::Utils;
use strict;
{ our $VERSION = '0.001'; }

use Exporter 'import';
use Module::Runtime qw< use_module >;

our @EXPORT_OK = qw< guard load_module pipeline resolve_module >;

sub guard {
   require Bot::ChatBots::Guard;
   return Bot::ChatBots::Guard->new(@_);
}

sub load_module { return use_module(resolve_module(@_)) }

sub pipeline {
   return $_[0] if (@_ == 1) && (ref($_[0]) eq 'CODE');

   my $opts = {};
   $opts = shift(@_) if (@_ && ref($_[0]) eq 'HASH');
   $opts = pop(@_)   if (@_ && ref($_[-1]) eq 'HASH');
   my $prefix = $opts->{prefix} // 'Bot::ChatBots';
   my @defs = map {
      my $r = ref $_;
      if (!$r) {
         '!' . resolve_module($_, $prefix);
      }
      elsif ($r eq 'ARRAY') {
         my ($name, @rest) = @$_;
         ['!' . resolve_module($_, $prefix), @rest];
      }
      else { $_ }
   } @_;
   require Data::Tubes;
   return Data::Tubes::pipeline(@defs, $opts);
} ## end sub pipeline

sub resolve_module {
   my ($name, $prefix) = @_;
   $prefix //= 'Bot::ChatBots';
   return $prefix . $name if substr($name, 0, 2) eq '::';
   return substr($name, 1) if substr($name, 0, 1) eq '!';
   return $prefix . '::' . $name if $name !~ m{::}mxs;
   return $name;
} ## end sub resolve_module

42;
