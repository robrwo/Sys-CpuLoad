use Test::Most;

plan skip_all => "no /proc/loadavg"
   unless -r "/proc/loadavg";

use_ok 'Sys::CpuLoad', 'proc_loadavg';

my @load = proc_loadavg();

cmp_deeply
  \@load,
  [ (re(qr/^\d+(\.\d+)?(e[\-\+]\d+)?$/)) x 3 ], 'proc_loadavg';

diag "@load";

done_testing;
