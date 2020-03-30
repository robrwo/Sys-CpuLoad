use Test::Most;

use File::Which qw/ which /;

my $path = which("uptime");

plan skip_all => "no uptime found"
    unless -x $path;

use_ok 'Sys::CpuLoad', 'uptime';

my @load = uptime();

cmp_deeply
  \@load,
  [ (re(qr/^\d+(\.\d+)?(e[\-\+]\d+)?$/)) x 3 ], 'uptime';

diag "@load";

done_testing;
