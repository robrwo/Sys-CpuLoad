use Test::Most;


use_ok 'Sys::CpuLoad', 'uptime';

my @load = uptime();

cmp_deeply
  \@load,
  [ (re(qr/^\d+(\.\d+)?(e[\-\+]\d+)?$/)) x 3 ], 'uptime';

diag "@load";

done_testing;
