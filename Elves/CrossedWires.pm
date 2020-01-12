package Elves::CrossedWires;

# SPDX-License-Identifier: MIT

use 5.026001;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
    %node_map
    %step_map
    $node_origin
    $step_count
    map_segment
    node_manhattan
    node_steps
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.01.03';

our %step_map = (
    A => {},
    B => {},
);

our $step_count;

our %node_map;

# The multipliers for moving in a given direction
my %shifts = (
    D => '0:-1',
    L => '-1:0',
    R => '1:0',
    U => '0:1',
);

# Routine to find the Manhattan Distance between two nodes
sub node_manhattan {
    my ($h_origin, $v_origin) = split ':', $_[0];
    my ($h_target, $v_target) = split ':', $_[1];
    return abs($h_target - $h_origin) + abs($v_target - $v_origin);
}

sub node_steps {
    return $step_map{A}{$_[1]} + $step_map{B}{$_[1]};
}

# The common point for comparing distances
# Subject to change by the calling module
our $node_origin;
# Routine to 'draw' on run of wire on the grid
sub map_vector {
# map_vector $_[2], $h_pos, $v_pos, $distance, $delta, $vertical;
    my ($symbol, $h_pos, $v_pos, $distance, $factor, $vertical) = @_;
    my ($first_pos, $node, $node_template);
    if ( $vertical ) {
        $node_template = "$h_pos:%d";
        $first_pos = $v_pos + $factor;
    } else {
        $node_template = "%d:$v_pos";
        $first_pos = $h_pos + $factor;
    }
    for (my $step = 0; $step < $distance; $step++) {
        $step_count++;
        $node = sprintf $node_template, $first_pos + $factor * $step;
        if ( ! defined $step_map{$symbol}{$node} ) {
            $step_map{$symbol}{$node} = $step_count;
        }
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
    my ($h_shift, $v_shift) = split ':', $shifts{$bearing};
    my $vertical = ( 0 == $h_shift )? 1 : 0;
    my $delta = (( $vertical )? $v_shift : $h_shift);
    map_vector $_[2], $h_pos, $v_pos, $distance, $delta, $vertical;
    return sprintf "%d:%d", $h_pos + $h_shift * $distance, $v_pos + $v_shift * $distance;
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
    %step_map
    $node_origin
    $step_count
    map_segment
    node_manhattan
    node_steps

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
