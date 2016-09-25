package Bot::ChatBots::Utils;
use strict;
{ our $VERSION = '0.001'; }

use Exporter 'import';
use Module::Runtime qw< use_module >;

our @EXPORT_OK = qw< load_module resolve_module >;

sub load_module { return use_module(resolve_module(@_)) }

sub resolve_module {
   my ($name, $prefix) = @_;
   $prefix //= 'Bot::ChatBots';
   return $prefix . $name if substr($name, 0, 2) eq '::';
   return substr($name, 1) if substr($name, 0, 1) eq '!';
   return $prefix . '::' . $name if $name !~ m{::}mxs;
   return $name;
} ## end sub resolve_module

42;
