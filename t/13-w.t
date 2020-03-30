use Test::Most;

use File::Which qw/ which /;

my $path = which("w");

plan skip_all => "no uptime found"
    unless -x $path;

use_ok 'Sys::CpuLoad', 'uptime';

no warnings 'once';

$Sys::CpuLoad::UPTIME = $path;

my @load = uptime();

cmp_deeply
  \@load,
  [ (re(qr/^\d+(\.\d+)?(e[\-\+]\d+)?$/)) x 3 ], 'uptime';

diag "@load";

done_testing;
