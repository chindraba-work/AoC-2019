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
use lib ".";

our $data_file;

my $solution_file;
my ($challenge_day, $challenge_part) = (@ARGV, 0, 0);

exit if ( 0 == $challenge_day );

if ( 0 eq $challenge_part ) {
    $solution_file = sprintf "Solutions/AoC-2019-%02d.pl", $challenge_day;
} else {
    $solution_file = sprintf "Solutions/AoC-2019-%02d_%s.pl", $challenge_day, lc($challenge_part);
}
$data_file = sprintf "Data/AoC-2019-%02d.txt", $challenge_day;

do {
    do $solution_file;
    exit;
} if ( -f $data_file && -f $solution_file );

if ( -f $data_file ) {
    say "The solutions for $challenge_day seem to be incomplete.";
} else {
    say "There is no data for $challenge_day. Nothing can be done with out data.";
}

1;