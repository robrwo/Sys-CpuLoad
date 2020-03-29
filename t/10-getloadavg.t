use Test::Most;

my $os = lc $^O;

plan skip_all => $os
    if $os !~ /^(darwin|dragonfly|(free|net|open)bsd|linux|solaris|sunos)$/;

use_ok 'Sys::CpuLoad', 'getloadavg';

my @load = getloadavg();

cmp_deeply
  \@load,
  [ (re(qr/^\d+(\.\d+)?(e[\-\+]\d+)?$/)) x 3 ], 'getloadavg';

diag "@load";

done_testing;
