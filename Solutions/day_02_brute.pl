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
load_code_stream(@elf_script);

# modify the program as instructed in the challenge
terminal_memory_access(1,12);
terminal_memory_access(2,2);

# run the program
elf_launch();

say "Program answer is ",terminal_memory_access(0);
say "==============";

exit unless $main::do_part_2;

# Part 2

say "\n=== PART 2 ===";

my $target_value = 19690720;
for my $noun (0..99) {
    for my $verb (0..99) {
        warm_boot();
        # load the given program into memory
        load_code_stream(@elf_script);
        terminal_memory_access(1,$noun);
        terminal_memory_access(2,$verb);
        elf_launch();
        if ( terminal_memory_access(0) == $target_value ) {
            say 100 * $noun + $verb, " = 100 * $noun + $verb and gives ", terminal_memory_access(0);
            say "==============";
            exit;
        }
    }
}

1;
