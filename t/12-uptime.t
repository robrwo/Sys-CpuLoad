use Test::Most;

use File::Which qw/ which /;

plan skip_all => "no uptime found"
    unless which("uptime");

use_ok 'Sys::CpuLoad', 'uptime';

my @load = uptime();

cmp_deeply
  \@load,
  [ (re(qr/^\d+(\.\d+)?(e[\-\+]\d+)?$/)) x 3 ], 'uptime';

diag "@load";

done_testing;
