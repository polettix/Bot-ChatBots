package Whatever::WH;
use strict;

use Moo;
with 'Bot::ChatBots::Role::Source';

sub class_custom_pairs {
   return (wow => 'people', this => 'goes');
}

1;
