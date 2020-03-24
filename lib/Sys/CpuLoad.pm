package Sys::CpuLoad;

# Copyright (c) 1999-2002 Clinton Wong. All rights reserved.
# This program is free software; you can redistribute it
# and/or modify it under the same terms as Perl itself.

use v5.6;

use strict;
use warnings;

use parent qw(Exporter DynaLoader);

use IO::File;

our @EXPORT    = qw();
our @EXPORT_OK = qw(load);

our $VERSION = '0.04';

bootstrap Sys::CpuLoad $VERSION;

=head1 NAME

Sys::CpuLoad - a module to retrieve system load averages.

=head1 DESCRIPTION

This module retrieves the 1 minute, 5 minute, and 15 minute load average
of a machine.

=head1 SYNOPSIS

 use Sys::CpuLoad;
 print '1 min, 5 min, 15 min load average: ',
       join(',', Sys::CpuLoad::load()), "\n";

=head1 AUTHOR

Originally written by Clinton Wong <clintdw@cpan.org>.

Maintained since 2020 by Robert Rothenberg <rrwo@cpan.org>.

=head1 COPYRIGHT

 Copyright (c) 1999-2002 Clinton Wong. All rights reserved.
 This program is free software; you can redistribute it
 and/or modify it under the same terms as Perl itself.

=cut

sub import {

    my $this = __PACKAGE__;
    my $os   = lc $^O;

    if ( -r '/proc/loadavg' && $os eq 'linux' ) {

        no strict 'refs'; ## no critic (ProhibitNoStrict)

        *{"${this}::load"} = sub {
            my $fh = IO::File->new( '/proc/loadavg', 'r' );
            if ( defined $fh ) {
                my $line = <$fh>;
                $fh->close();
                if ( $line =~ /^(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)/ ) {
                    return ( $1, $2, $3 );
                }
            }
            return (undef) x 3;
        };

    }
    elsif ( $os eq 'freebsd' || $os eq 'openbsd' ) {

        no strict 'refs'; ## no critic (ProhibitNoStrict)

        *{"${this}::load"} = \&_getbsdload;

    }
    else {

        no strict 'refs'; ## no critic (ProhibitNoStrict)

        *{"${this}::load"} = sub {

            local %ENV = %ENV;
            $ENV{'LC_NUMERIC'} =
              'POSIX';    # ensure that decimal separator is a dot

            my $fh = IO::File->new('/usr/bin/uptime|');
            if ( defined $fh ) {
                my $line = <$fh>;
                $fh->close();
                if ( $line =~
                    /(\d+\.\d+)\s*,\s+(\d+\.\d+)\s*,\s+(\d+\.\d+)\s*$/ )
                {
                    return ( $1, $2, $3 );
                }
            }
            return (undef) x 3;
        };
    }

    goto &Exporter::import;
}

1;
