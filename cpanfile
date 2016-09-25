requires 'perl',     '5.010';
requires 'Log::Any', '1.042';
requires 'Mo',       '0.040';

on test => sub {
   requires 'Test::More', '0.88';
   requires 'Path::Tiny', '0.096';
};

on develop => sub {
   requires 'Path::Tiny',        '0.096';
   requires 'Template::Perlish', '1.52';
};
