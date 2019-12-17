package Elves::FuelCounterUpper;

# SPDX-License-Identifier: MIT

use 5.026001;
use strict;
use warnings;
use Elves::GetData qw(read_lines);
use List::Util qw(sum);

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
	fuel_counter_upper
) ] );

our @EXPORT_OK = qw(
	fuel_counter_upper
);

our @EXPORT = qw(
	fuel_counter_upper
);

our $VERSION = '0.01.00';


# Instructions:
#
# Fuel required to launch a given module is based on its mass.
# Specifically, to find the fuel required for a module, take its mass,
# divide by three, round down, and subtract 2.
#
# The Fuel Counter-Upper needs to know the total fuel requirement. To
# find it, individually calculate the fuel needed for the mass of each
# module (your puzzle input), then add together all the fuel values.
#
# What is the sum of the fuel requirements for all of the modules on
# your spacecraft?

# Instructions addendum:
# 
# Fuel itself requires fuel just like a module - take its mass, divide
# by three, round down, and subtract 2. However, that fuel also requires
# fuel, and that fuel requires fuel, and so on. Any mass that would
# require negative fuel should instead be treated as if it requires zero
# fuel; the remaining mass, if any, is instead handled by wishing really
# hard, which has no mass and is outside the scope of this calculation.
# 
# So, for each module mass, calculate its fuel and add it to the total.
# Then, treat the fuel amount you just calculated as the input mass and
# repeat the process, continuing until a fuel requirement is zero or
# negative.


my $fuel_factor = 3;
my $fuel_adjust = 2;

my $fuel_table_format = "| %11u | %13u |";
my $fuel_table_header = "| Module Mass | Fuel Required |";
my $fuel_table_marker = "|-------------|---------------|";
my $fuel_table_total  = "|  Total Fuel | %13u |";

sub mass_to_fuel {
    my $mass = shift;
    return sprintf( "%u", $mass / $fuel_factor) - $fuel_adjust;
}

sub real_mass_to_fuel {
    my $mass = shift;
    my $fuel = 0;
    my $fuel_mass = mass_to_fuel $mass;
    while ( 0 < $fuel_mass ) {
        $fuel += $fuel_mass;
        $fuel_mass = mass_to_fuel $fuel_mass;
    }
    return $fuel;
}

sub find_module_fuel_cost {
    my $mass = shift;
    my $fuel = real_mass_to_fuel $mass;
    say sprintf $fuel_table_format, $mass, $fuel if $main::show_progress;
    return $fuel;
}

sub find_fuel_total {
    my $source_file = shift;
    my $total_fuel = sum 
        map {
            find_module_fuel_cost $_; 
        } read_lines $source_file;
    return $total_fuel;
}

sub fuel_counter_upper {
    my $data_file = shift;
    if ($main::show_progress) {
        say $fuel_table_marker;
        say $fuel_table_header;
        say $fuel_table_marker;
    }
    my $needed_fuel = find_fuel_total $data_file;
    if ($main::show_progress) {
        say $fuel_table_marker;
    }
    say sprintf $fuel_table_total, $needed_fuel;
    if ($main::show_progress) {
        say $fuel_table_marker;
    }
    return $needed_fuel;
}

1;
__END__
=head1 NAME

Elves::FuelCounterUpper - Perl extension for finding the total fuel
costs. Part of the daily challenges of Advent of Code

=head1 SYNOPSIS

  use Elves::FuelCounterUpper;

=head1 DESCRIPTION

Read the contents of the input file, find the fuel for each module,
return the total fuel needs

=head2 EXPORT

fuel_counter_upper

=head1 AUTHOR

Chindraba, E<lt>aoc@chindraba.workE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright © 2019  Chindraba (Ronald Lamoreaux)
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
