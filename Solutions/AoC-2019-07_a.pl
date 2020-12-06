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
use Elves::Permutator qw( permutate );
use Elves::GetData qw( read_comma_list );

my $VERSION = '0.19.07';

my @setting_list;

# Collection of all computed thrust values
# Key is the input values, colon separated
# Value is the resultant thrust value
my %thruster_matrix;
# The current best thrust value
my $max_thrust = 0;
# The amplifier inputs to get this thrust
my @max_inputs = ();

# the program to run repeatedly
my @elf_script = read_comma_list("Data/AoC-2019-07.txt");
# Clear ARGV so it can be used internally
$#ARGV = -1;
# Redirect ElfComp output to memory
filter_output(1);

sub store_thruster_value {
    my $thruster_value = shift;
    my @inputs = @_;
    $thruster_matrix{join(':',@inputs)} = $thruster_value;
    if ( $thruster_value > $max_thrust ) {
        $max_thrust = $thruster_value;
        @max_inputs = @inputs;
say join(':',@inputs), " => ", $thruster_value, " **";
    } else {
say join(':',@inputs), " => ", $thruster_value;
    }
}

sub find_thrust_input {
    unshift(@ARGV, 0);
    my @amp_settings = @{$_[0]};
    foreach my $amp_setting (@amp_settings) {
        unshift(@ARGV, $amp_setting);
        load_code_stream(@elf_script);
        elf_launch();
        push(@ARGV, (elf_output)[0]);
        warm_boot();
    }
    store_thruster_value(shift(@ARGV),@amp_settings);    
}

my @amp_range = ( 0 .. 4 );
permutate(\&find_thrust_input, $#amp_range, [@amp_range]);

say "Max thrust is ",$max_thrust," using inputs of ",join(':',@max_inputs);

1;
