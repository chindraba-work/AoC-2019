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
    restart
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.19.02';

*load_code       = *IntCode::AsmComp::load_memory;
*memory_terminal = *IntCode::AsmComp::access_memory;
*raw_asm         = *IntCode::AsmComp::command;

my ($elf_index, $op1, $op2, @parameter_mode) = (0) x 6;

my @mode_list = qw(
    Absolute
    Immediate
);

my %elf_asm = (
    99 => sub { return ('STP'); },
    1 => sub { return (
            LDA => $mode_list[$parameter_mode[0]], elf_next(),
            ADC => $mode_list[$parameter_mode[1]], elf_next(),
            STA => $mode_list[$parameter_mode[2]], elf_next(),
        )},
    2 => sub { return (
            LDA => $mode_list[$parameter_mode[0]], elf_next(),
            MUL => $mode_list[$parameter_mode[1]], elf_next(),
            STA => $mode_list[$parameter_mode[2]], elf_next(),
        )},
);

sub restart {
    reboot();
    $elf_index = 0;
}

sub elf_next {
    return memory_terminal($elf_index++);
}

sub elf_step {
    ($op2, $op1, @parameter_mode) = (reverse(split('', elf_next())),('0') x 5)[0..4];
    my @asm_snippet = $elf_asm{10 * $op1 + $op2}();
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
    restart

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
