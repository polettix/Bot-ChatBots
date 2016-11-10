use strict;
use Test::More tests => 19;
use Test::Exception;
use Mojolicious::Lite;
use Test::Mojo;

BEGIN {
   (my $subdir = __FILE__) =~ s{t$}{d}mxs;
   unshift @INC, $subdir;
}

throws_ok { require WH2 } qr{missing\ process}mxs,
  'one method is not implemented';

my $wh;
lives_ok {
   require WH;
   $wh = WH->new(app => app(), path => '/wh');
}
'minimal formally compliant WebHook';

isa_ok $wh, 'WH';

lives_ok { $wh->install_route } 'install_route';

my $t = Test::Mojo->new;

{
   $wh->reset;
   $t->post_ok('/wh')->status_is(204);
   is scalar($wh->processed), 1, 'something arrived to the process phase';
   my ($processed) = $wh->processed;
   is_deeply $processed->{source}, {what => 'ever'}, 'source';
   is_deeply $processed->{batch}, {count => 1, total => 1}, 'batch';
   ok exists($processed->{update}), 'update exists';
   is $processed->{update}, undef, 'update is undefined';
   ok exists($processed->{stash}), 'stash exists';
}

{
   $wh->reset;
   $t->post_ok('/wh', json => {hey => 'you'})->status_is(204);
   is scalar($wh->processed), 1, 'something arrived to the process phase';
   my ($processed) = $wh->processed;
   is_deeply $processed->{source}, {what => 'ever'}, 'source';
   is_deeply $processed->{batch}, {count => 1, total => 1}, 'batch';
   is_deeply $processed->{update}, {hey => 'you'}, 'update';
   ok exists($processed->{stash}), 'stash exists';
}

done_testing();
