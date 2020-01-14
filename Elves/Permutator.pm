package Elves::Permutator;

# SPDX-License-Identifier: MIT

use 5.026001;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
	permutate
    permutations
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	permutate
    permutations
);

our $VERSION = '0.19.07';

sub permutate {
    my( $worker, $count, $set ) = @_;
    ( $count ) || $worker->($set) && return;
    foreach my $index (0 .. $count) {
        permutate ( $worker, $count - 1, $set );
        my $swap = ( $count % 2 )? 0 : $index;
        @{$set}[$swap, $count] = @{$set}[$count, $swap];
    }
}

sub permutations {
   my ($limit) = (shift);
   my @permutations = ([+1]);
   for my $index ( 0 .. $limit ) {
      my $sign = -1;
      @permutations = map {
         my ($direction, @previous) = @$_;
         map [$sign *= -1, @previous[0..$_-1], $index, @previous[$_..$#previous]],
            $direction < 0 ? 0 .. @previous : reverse 0 .. @previous;
      } @permutations;
   }
   @permutations;
}

1;
__END__

=head1 NAME

Elves::Permutator - Perl extension for processing and generating 
permutations. Part of the solutions for the daily challenges in the
Advent of Code

=head1 SYNOPSIS

  use Elves::Permutator;

=head1 DESCRIPTION

Routines to generate a sequence of permutations or to iterate through
such a series.

permutate    uses Heap's Algorithm, expects the worker sub to be passed
permutations uses the Steinhaus–Johnson–Trotter algorithm, returns a list

=head2 EXPORT

	permutate
    permutations

=head1 AUTHOR

Chindraba, E<lt>aoc@chindraba.workE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright © 2020  Chindraba (Ronald Lamoreaux)
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
