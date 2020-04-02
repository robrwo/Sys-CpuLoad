use Test::Most;
use Test::Warnings;

use Scalar::Util 'looks_like_number';

my $os = lc $^O;

plan skip_all => $os
    if $os !~ /^(darwin|dragonfly|(free|net|open)bsd|linux|solaris|sunos)$/;

use_ok 'Sys::CpuLoad', 'getloadavg';

my @load = getloadavg();

cmp_deeply
  \@load,
  [ (code(\&looks_like_number)) x 3 ], 'load';

diag "@load";

done_testing;
