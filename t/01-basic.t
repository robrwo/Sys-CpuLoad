use Test::Most;

use_ok 'Sys::CpuLoad', 'load';

my @load = load();

cmp_deeply
  \@load,
  [ (re(qr/^\d(\.\d+)?$/)) x 3 ], 'load';

done_testing;
