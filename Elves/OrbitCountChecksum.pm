package Elves::OrbitCountChecksum;

# SPDX-License-Identifier: MIT

use 5.026001;
use strict;
use warnings;
use Elves::GetData qw(read_lines);

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
	    add_orbit
	    orbit_checksum
	    trace_route
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.19.25';

my @tally_list = ('COM');
my $running_sum  = 0;
my %orbit_map;
my %tail_map;
my %orbit_sums = ( COM => 0 );

sub add_orbit {
    my $input = shift;
    my ($inner, $outer) = split /\)/, $input;
    if ( ! defined $orbit_map{$inner} ) {
        @orbit_map{$inner} = [$outer];
    } else {
        push @{$orbit_map{$inner}}, $outer;
    }
    $orbit_sums{$outer} = 1;
    $tail_map{$outer} = $inner;
}

sub orbit_weight {
    my $inner = $_[0];
    if ( defined $orbit_map{$inner} ) {
        for my $outer (@{$orbit_map{$inner}}) {
            $orbit_sums{$outer} += $orbit_sums{$inner};
            $running_sum += $orbit_sums{$outer};
            push @tally_list, $outer;
        }
    }
}

sub orbit_checksum {
    while ( @tally_list ) {
        my $target = shift @tally_list;
        orbit_weight($target);
    }
    return $running_sum;
}

sub trace_route {
    my @route;
    my $target = shift;
    while ( 'COM' ne $target ) {
        $target = $tail_map{$target};
        unshift @route, $target;
    }
    return (@route);
}

1;
__END__
=head1 NAME

Elves::OrbitCountChecksum

=head1 SYNOPSIS

  use Elves::OrbitCountChecksum;

=head1 DESCRIPTION

Calculate checksum of orbits recorded in the map

=head2 EXPORT

    add_orbit
    orbit_checksum
    trace_route

=head1 AUTHOR

Chindraba, E<lt>aoc@chindraba.workE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright © 2020  Chindraba (Ronald Lamoreaux)
                  <aoc@chindraba.work>
- All Rights Reserved

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use, copy,
modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

=cut
