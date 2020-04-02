use Test::Most;
use Test::Warnings;

use File::Which qw/ which /;
use Scalar::Util 'looks_like_number';

my $path = which("uptime");

plan skip_all => "no uptime found"
    unless $path && -x $path;

use_ok 'Sys::CpuLoad', 'uptime';

my @load = uptime();

cmp_deeply
  \@load,
  [ (code(\&looks_like_number)) x 3 ], 'load';

diag "@load";

done_testing;
