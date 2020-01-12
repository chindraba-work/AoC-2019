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

my $target_value = 19690720;
my ($baseline, $per_noun, $per_verb, $nouns, $verbs);

# Find the baseline value
load_code_file($main::data_file);
terminal_memory_access(1,0);
terminal_memory_access(2,0);
elf_launch();
$baseline = terminal_memory_access(0);

# Find the delta/noun
warm_boot();
load_code_file($main::data_file);
terminal_memory_access(1,1);
terminal_memory_access(2,0);
elf_launch();
$per_noun = terminal_memory_access(0) - $baseline;

# Find number of nouns needed
$nouns = sprintf "%d", (($target_value - $baseline) / $per_noun);

# Find the delta/verb
warm_boot();
load_code_file($main::data_file);
terminal_memory_access(1,0);
terminal_memory_access(2,1);
elf_launch();
$per_verb = terminal_memory_access(0) - $baseline;

# Find the number of verbs needed
$verbs = ($target_value - $baseline - $nouns * $per_noun)/$per_verb;

# Show the final result
warm_boot();
load_code_file($main::data_file);
terminal_memory_access(1,$nouns);
terminal_memory_access(2,$verbs);
elf_launch();

say 100 * $nouns + $verbs, " = 100 * $nouns + $verbs and gives ", terminal_memory_access(0);
1;