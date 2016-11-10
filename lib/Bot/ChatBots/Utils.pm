package Bot::ChatBots::Utils;
use strict;
{ our $VERSION = '0.001013'; }

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
   $opts->{tap} //= sub { ($_[0]->())[0] }
     unless exists $opts->{pump};
   Data::Tubes::pipeline(@defs, $opts);
} ## end sub pipeline

sub resolve_module {
   my ($name, $prefix) = @_;
   $prefix //= 'Bot::ChatBots';
   return substr($name, 1) if $name =~ m{\A[+^]}mxs;
   $name =~ s{^(::)?}{::}mxs;    # ensure separating "::" in front of $name
   return $prefix . $name;
} ## end sub resolve_module

42;
