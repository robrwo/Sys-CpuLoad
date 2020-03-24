package Sys::CpuLoad;

# ABSTRACT: retrieve system load averages

# Copyright (c) 1999-2002 Clinton Wong. All rights reserved.
# This program is free software; you can redistribute it
# and/or modify it under the same terms as Perl itself.

use v5.6;

use strict;
use warnings;

use parent qw(Exporter);

use IO::File;
use XSLoader;

our @EXPORT    = qw();
our @EXPORT_OK = qw(load);

our $VERSION = '0.10';

XSLoader::load 'Sys::CpuLoad', $VERSION;

=head1 DESCRIPTION

This module retrieves the 1 minute, 5 minute, and 15 minute load average
of a machine.

=head1 SYNOPSIS

 use Sys::CpuLoad 'load';
 print '1 min, 5 min, 15 min load average: ',
       join(',', load()), "\n";

=export load

This method returns the load average for 1 minute, 5 minutes and 15
minutes as an array.

On Linux systems it will attempt to use F</proc/loadavg>.

On FreeBSD and OpenBSD systems, it will make a call to C<getloadavg>.

Otherwise, it will attempt to parse the output of C<uptime>.

On error, it will return an array of C<undef> values.

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

=head1 SEE ALSO

L<Sys::CpuLoadX>

=cut

1;
