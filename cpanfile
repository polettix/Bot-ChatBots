requires 'perl',            '5.010';
requires 'Log::Any',        '1.042';
requires 'Mo',              '0.040';
requires 'Moo',             '2.002005';
requires 'Module::Runtime', '0.014';
requires 'Ouch',            '0.0410';
requires 'Try::Tiny',       '0.27';

on test => sub {
   requires 'Test::More',      '0.88';
   requires 'Path::Tiny',      '0.096';
   requires 'Mock::Quick',     '1.111';
   requires 'Test::Exception', '0.43';
};

on develop => sub {
   requires 'Path::Tiny',        '0.096';
   requires 'Template::Perlish', '1.52';
   requires 'Mojolicious',       '7.10';
};
