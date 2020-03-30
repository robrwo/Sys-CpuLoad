use Test::Most;

use File::Which qw/ which /;

plan skip_all => "no uptime found"
    unless which("w");

use_ok 'Sys::CpuLoad', 'uptime';

no warnings 'once';

$Sys::CpuLoad::UPTIME = which("w");

my @load = uptime();

cmp_deeply
  \@load,
  [ (re(qr/^\d+(\.\d+)?(e[\-\+]\d+)?$/)) x 3 ], 'uptime';

diag "@load";

done_testing;
