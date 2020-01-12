package IntCode::ElfComp;

# SPDX-License-Identifier: MIT

use 5.026001;
use strict;
use warnings;
use Elves::GetData qw ( read_comma_list );
use IntCode::ElfComp::ElfCodes;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
	elf_launch
	enable_dump
	load_code_file
	terminal_memory_access
	warm_boot
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.19.02';

my $stopped;

*terminal_memory_access = *IntCode::ElfComp::ElfCodes::memory_terminal;
*warm_boot              = *IntCode::ElfComp::ElfCodes::restart;

sub enable_dump {
    if ( 0 < @_  && 1 == $_[0] ) {
        raw_asm('SED');
    } else {
        raw_asm('CLD');
    }
}

sub load_code_file {
    load_code(read_comma_list(@_));
}

sub elf_launch {
    $stopped = undef;
    $stopped = elf_step()
        until $stopped;
}

1;
__END__

=head1 NAME

IntCode::ElfComp

=head1 SYNOPSIS

  use IntCode::ElfComp;

=head1 DESCRIPTION

The Interger Computer the elves need to help Santa in the Advent of
Code challenges for 2019.

=head2 EXPORT

    elf_launch
    enable_dump
    load_code_file
    terminal_memory_access
    warm_boot

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
