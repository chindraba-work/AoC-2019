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
use IntCode::ElfComp;
use Elves::GetData qw( read_comma_list );

my $VERSION = '0.19.07';

# Retrieve the ElfScript file
my @elf_script = read_comma_list($main::puzzle_data_file);

# Part 1
say "=== PART 1 ===";

# load the given program into memory
warm_boot();
load_code_stream(@elf_script);
# Clear ARGV in preparation for using it with the ElfComp
$#ARGV = -1;
# Set the test code in ARGV
push @ARGV, 1;
# run the program
elf_launch();

say "==============";

exit unless $main::do_part_2;

# Part 2

say "=== PART 2 ===";

# load the given program into memory
warm_boot();
load_code_stream(@elf_script);
# Clear ARGV in preparation for using it with the ElfComp
$#ARGV = -1;
# Set the test code in ARGV
push @ARGV, 5;
# run the program
elf_launch();

say "==============";


1;
