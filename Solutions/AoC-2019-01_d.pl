#!/usr/bin/perl

# SPDX-License-Identifier: MIT

########################################################################
#                                                                      #
#  This file is part of the solution set for the programming puzzles   #
#  presented by the 2019 Advent of Code challenge.                     #
#  See: https://adventofcode.com/2019                                  #
#                                                                      #
#  Copyright © 2019, 2020  Chindraba (Ronald Lamoreaux)                #
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
use IntCode::AsmComp;
use Elves::GetData qw( read_lines );

my $VERSION = '0.19.07';

my @module_data = read_lines($main::data_file);
my $module_count_value = @module_data;

my ($fuel_factor_value, $fuel_adjust_value) = (3,2);
my (
    $mass_list,
    $fuel_list,
    $module_count,
    $fuel_factor,
    $fuel_adjust,
    $running_total_fuel,
    $current_mass,
    $module_total_fuel,
) = (100..110);

my @code_set = (
    LDA => Immediate => $fuel_factor_value,
    STA => Absolute => $fuel_factor,
    LDA => Immediate => $fuel_adjust_value,
    STA => Absolute => $fuel_adjust,
    LDA => Immediate => $module_count_value,
    STA => Absolute => $module_count,
    LDA => Immediate => 0,
    STA => Absolute => $mass_list,
    LDA => Immediate => 0,
    STA => Absolute => $running_total_fuel,
    CMP => Absolute => $module_count,
    BPL => Relative => 51,
    TAI =>
    LDA => List => $mass_list,
    STA => Absolute => $current_mass,
    LDA => Immediate => 0,
    STA => Absolute => $module_total_fuel,
    LDA => Absolute => $current_mass,
    DIV => Absolute => $fuel_factor,
    SBC => Absolute => $fuel_adjust,
    BMI => Relative => 12,
    STA => Absolute => $current_mass,
    ADC => Absolute => $module_total_fuel,
    STA => Absolute => $module_total_fuel,
    JMP => Relative => -24,
    LDA => Absolute => $module_total_fuel,
    ADC => Absolute => $running_total_fuel,
    STA => Absolute => $running_total_fuel,
    INI =>
    TIA =>
    JMP => Relative => -57,
    OTD => Absolute => $running_total_fuel,
);


sub main {
    asm_boot((code => [ @code_set ], data => [ @module_data ]));
    say "Fuel required is ", pop(@ARGV);
}

main();

1;
