#!/usr/bin/perl

# SPDX-License-Identifier: MIT

########################################################################
#                                                                      #
#  This file is part of the solution set for the programming puzzles   #
#  presented by the 2019 Advent of Code challenge.                     #
#  See: https://adventofcode.com/2019                                  #
#                                                                      #
#  Copyright © 2020  Chindraba (Ronald Lamoreaux)                      #
#                    <aoc@chindraba.work>                              #
#  - All Rights Reserved                                               #
#                                                                      #
#  Permission is hereby granted, free of charge, to any person         #
#  obtaining a copy of this software and associated documentation      #
#  files (the "Software"), to deal in the Software without             #
#  restriction, including without limitation the rights to use, copy,  #
#  modify, merge, publish, distribute, sublicense, and/or sell copies  #
#  of the Software, and to permit persons to whom the Software is      #
#  furnished to do so, subject to the following conditions:            #
#                                                                      #
#  The above copyright notice and this permission notice shall be      #
#  included in all copies or substantial portions of the Software.     #
#                                                                      #
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,     #
#  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF  #
#  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND               #
#  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS #
#  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN  #
#  ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN   #
#  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE    #
#  SOFTWARE.                                                           #
#                                                                      #
########################################################################

use 5.026001;
use strict;
use warnings;
use Elves::GetData qw(slurp_data);
use Elves::CrossedWires;

my @file_data = slurp_data "Data/AoC-2019-03.txt";

my %wires = (
    A => [(split ',', $file_data[0])],
    B => [(split ',', $file_data[1])],
);

# Set the origin for mapping and comparisons
$node_origin = '0:0';

for my $wire (keys %wires) {
    # Set the starting point for mapping the wire
    my $current_node = $node_origin;
    # Map one of the wires
    for my $segment (@{ $wires{$wire} }) {
        $current_node = map_segment $current_node, $segment, $wire;
    }
}

# Mark the origin point as such, cancelling it being recorded as a crossover
$node_map{$node_origin} = 'ORIGIN';

my @crossovers = ();
while ( my ($key, $value) = each %node_map ) {
    if ( "X" eq $value ) {
        push @crossovers, $key;
    }
}
@crossovers = sort { node_manhattan($node_origin, $a) <=> node_manhattan($node_origin, $b) } @crossovers;

# Report the results
say "Closest crossover is ",node_manhattan($node_origin, $crossovers[0])," nodes from the origin at ",$crossovers[0];

1;
