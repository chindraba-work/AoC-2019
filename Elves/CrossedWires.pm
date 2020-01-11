package Elves::CrossedWires;

# SPDX-License-Identifier: MIT

use 5.026001;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
    %node_map
    $node_origin
    map_segment
    node_compare
    node_manhattan
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.01.03';

our %node_map;

# The multipliers for moving in a given direction
my %h_shift = (
    D => 0,
    L => -1,
    R => 1,
    U => 0,
);
my %v_shift = (
    D => -1,
    L => 0,
    R => 0,
    U => 1,
);

# Routine to find the Manhattan Distance between two nodes
sub node_manhattan {
    my ($h_origin, $v_origin) = split ':', $_[0];
    my ($h_target, $v_target) = split ':', $_[1];
    return abs($h_target - $h_origin) + abs($v_target - $v_origin);
}

# The common point for comparing distances
# Subject to change by the calling module
our $node_origin;

# Compare, for sorting purposes, two nodes based on their Manhattan Distance from a common point
sub node_compare {
    return node_manhattan($node_origin, $a) <=> node_manhattan($node_origin, $b);
}

# Routine to 'draw' on run of wire on the grid
sub map_vector {
    my ($symbol, $h_pos, $v_pos, $delta, $vertical) = @_;
    my ($first_pos, $last_pos, $node, $node_template, $step);
    if ( $vertical ) {
        $node_template = "$h_pos:%d";
        if ( 0 < $delta ) {
            $first_pos = $v_pos;
            $last_pos  = $v_pos + $delta;
        } else {
            $first_pos = $v_pos + $delta;
            $last_pos  = $v_pos;
        }
    } else {
        $node_template = "%d:$v_pos";
        if ( 0 < $delta ) {
            $first_pos = $h_pos;
            $last_pos  = $h_pos + $delta;
        } else {
            $first_pos = $h_pos + $delta;
            $last_pos  = $h_pos;
        }
    }
    for $step ($first_pos..$last_pos) {
        $node = sprintf $node_template, $step;
        if ( ! defined $node_map{$node} ) {
            $node_map{$node} = $symbol;
        } elsif ( $symbol ne $node_map{$node} ) {
            $node_map{$node} = 'X';
        }
    }
}

# Routine to convert the instruction into segments to map on the grid
sub map_segment {
    my ($h_pos, $v_pos) = split ':', $_[0];
    my ($bearing, $distance) = ($_[1] =~ /([UDLR])(\d+)/);
    my $h_delta = $h_shift{$bearing} * $distance;
    my $v_delta = $v_shift{$bearing} * $distance;
    if ( 0 != $h_delta ) {
        map_vector $_[2], $h_pos, $v_pos, $h_delta, 0;
    } else{
        map_vector $_[2], $h_pos, $v_pos, $v_delta, 1;
    }
    return sprintf "%d:%d", $h_pos + $h_delta, $v_pos + $v_delta;
}

1;
__END__
=head1 NAME

Elves::CrossedWires- Perl extension for finding the crossed wires in a
control panel. Part of the daily challenges of Advent of Code

=head1 SYNOPSIS

  use Elves::CrossedWires;

=head1 DESCRIPTION

Routines for handling the mapping of wires on the control panel and
marking crossover points, and dealing with the Manhattand distances
between points for sorting the list of cross overs.

=head2 EXPORT

    %node_map
    $node_origin
    map_segment
    node_compare
    node_manhattan

=head1 AUTHOR

Chindraba, E<lt>aoc@chindraba.workE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright © 2020 Chindraba (Ronald Lamoreaux)
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
