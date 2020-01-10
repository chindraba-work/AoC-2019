package IntCode::ElfComp::ElfCodes;

# SPDX-License-Identifier: MIT

use 5.026001;
use strict;
use warnings;
use IntCode::AsmComp;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw (
    elf_step
    load_code
    memory_terminal
    raw_asm
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.01.02';

*load_code       = *IntCode::AsmComp::load_memory;
*memory_terminal = *IntCode::AsmComp::access_memory;
*raw_asm         = *IntCode::AsmComp::command;

my $elf_index = 0;

my %elf_asm = (
    99 => sub { return ('STP'); },
    1 => sub { return (
            LDA => Absolute => elf_next(),
            ADC => Absolute => elf_next(),
            STA => Absolute => elf_next(),
        )},
    2 => sub { return (
            LDA => Absolute => elf_next(),
            MUL => Absolute => elf_next(),
            STA => Absolute => elf_next(),
        )},
);

sub elf_next {
    return memory_terminal($elf_index++);
}

sub elf_step {
    my @asm_snippet = $elf_asm{elf_next()}();
    load_program(@asm_snippet);
    return step_application();
}


1;
__END__

=head1 NAME

IntCode::ElfComp::ElfCodes

=head1 SYNOPSIS

  use IntCode::ElfComp::ElfCodes;

=head1 DESCRIPTION

Conversion between the opcodes of the Elves computer, to asmcodes in
the AsmComp computer. Part of the 2019 Advent of Code challenges.

=head2 EXPORT

    elf_step
    load_code
    memory_terminal
    raw_asm

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
