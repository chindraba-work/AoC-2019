package Elves::GetData;

# SPDX-License-Identifier: MIT

use 5.026001;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
	slurp_data
	read_lines
	read_comma_list
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.19.01';

# Presumption is that none of the data files will be extremely large,
# and should be easily handled by system memory.
#
# All files will be slurped.


sub slurp_data {
# Slurp the file into an array of lines.
# Pathname of the data file to read is only argument
# Return array of lines, or scalar of lines, by context
    return unless defined wantarray;
    my @puzzle_data = do{local(@ARGV) = shift; <>};
    chomp @puzzle_data;
    return wantarray ? @puzzle_data : "@puzzle_data";
}

sub read_lines {
# Read the multi-line file with one item per line
# Pathname of the data file to read is first argument
# Retrun: array of the elements
    return unless defined wantarray;
    my @puzzle_data = slurp_data shift;
    return @puzzle_data;
}

sub read_comma_list {
# Read the one-line file and split on given string, comma by default
#    If the file is NOT a one-liner, the lines will be joined with a
#    space, loosing any concept of "lines"
# Pathname of the data file to read is first argument
# Delimiter is, optionally, the second argument
# Return: list of items on the line
    return unless defined wantarray;
    my $puzzle_data = slurp_data shift;
    my $delimiter = shift || ',';
    my @data_list = split $delimiter, $puzzle_data;
    return @data_list;
}

1;
__END__

=head1 NAME

Elves::GetData - Perl extension for processing the data files in the
daily challenges of Advent of Code

=head1 SYNOPSIS

  use Elves::GetData qw( :all );

=head1 DESCRIPTION

Read the contents of the file for the day, and parse the results into
one of the forms needed for the challenge.

=head2 EXPORT

None by default.

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
