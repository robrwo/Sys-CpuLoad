package Sys::CpuLoad;

# ABSTRACT: retrieve system load averages

# Copyright (c) 1999-2002 Clinton Wong. All rights reserved.
# This program is free software; you can redistribute it
# and/or modify it under the same terms as Perl itself.

use v5.6;

use strict;
use warnings;

use parent qw(Exporter);

use File::Which qw(which);
use IO::File;
use IPC::Run3 qw(run3);
use XSLoader;

our @EXPORT    = qw();
our @EXPORT_OK = qw(load getloadavg proc_loadavg uptime);

our $VERSION = '0.31';

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

On Linux, Solaris, FreeBSD, NetBSD and OpenBSD systems, it will make a
call to L</getloadavg>.

If F</proc/loadavg> is available on non-Cygwin systems, it
will call L</proc_loadavg>.

Otherwise, it will attempt to parse the output of C<uptime>.

On error, it will return an array of C<undef> values.

As of v0.29, you can override the default function by changing
C<$Sys::CpuLoad::LOAD>:

  use Sys::CpuLoad 'load';

  no warnings 'once';

  $Sys::CpuLoad::LOAD = 'uptimr';

  @load = load();

If you are writing code to work on multiple systems, you should use
the C<load> function.  But if your code is intended for specific systems,
then you should use the appropriate function.

=cut

our $LOAD;

sub load {
    return getloadavg(@_)   if $LOAD eq 'getloadavg';
    return proc_loadavg(@_) if $LOAD eq 'proc_loadavg';
    return uptime(@_)       if $LOAD eq 'uptime';
    die "Unknown function: $LOAD";
}

=export getloadavg

This is a wrapper around the system call to C<getloadavg>.

If this call is unavailable, or it is fails, it will return C<undef>.

Added in v0.22.

=export proc_loadavg

If F</proc/loadavg> is available, it will be used.

If the data cannot be parsed, it will return C<undef>.

Added in v0.22.

=cut

sub proc_loadavg {

    if ( -r '/proc/loadavg' ) {

        my $fh = IO::File->new( '/proc/loadavg', 'r' );
        if ( defined $fh ) {
            my $line = <$fh>;
            $fh->close();
            if ( $line =~ /^(\d+\.\d+)\s+(\d+\.\d+)\s+(\d+\.\d+)/ ) {
                return ( $1, $2, $3 );
            }
        }
    }

    return undef;
}

=head2 uptime

Parse the output of uptime.

If the L<uptime> executable cannot be found, or the output cannot be
parsed, it will return C<undef>.

Added in v0.22.

As of v0.24, you can override the executable path by setting
C<$Sys::CpuLoad::UPTIME>, e.g.

  use Sys::CpuLoad 'uptime';

  no warnings 'once';

  $Sys::CpuLoad::UPTIME = '/usr/bin/w';

  @load = uptime();

=cut

our $UPTIME;

sub uptime {
    local %ENV = %ENV;
    $ENV{'LC_NUMERIC'} = 'POSIX'; # ensure that decimal separator is a dot

    $UPTIME ||= which("uptime") or
        return undef;

    run3($UPTIME, \undef, \my $line);
    return undef if $? || !defined($line);
    if ( $line =~ /(\d+[,.]\d+)\s*,?\s+(\d+[,.]\d+)\s*,?\s+(\d+[,.]\d+)\s*$/m )
    {
        return ( map { my $n = $_; $n =~ tr/,/./; $n + 0 } ( $1, $2, $3 ) );
    }
    return undef;
}

sub BEGIN {

    my $this = __PACKAGE__;
    my $os   = lc $^O;

    if ( $os =~ /^(darwin|dragonfly|(free|net|open)bsd|linux|solaris|sunos)$/ ) {
        $LOAD = 'getloadavg';
    }
    elsif ( -r '/proc/loadavg' && $os ne 'cygwin' ) {
        $LOAD = 'proc_loadavg';
    }
    else {
        $LOAD = 'uptime';
    }

}

=head1 SEE ALSO

L<Sys::CpuLoadX>

=cut

1;
