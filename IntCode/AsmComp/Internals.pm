package IntCode::AsmComp::Internals;

# SPDX-License-Identifier: MIT

use 5.026001;
use strict;
use warnings;
require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = (
    'registers' => [
        qw(
            %process_registers
        )
    ],
    'flag_control' => [
        qw(
            %status_flags
        )
    ],
    'memory' => [
        qw(
            %address_mode
            @stack_heap
            @core_ram
            @program_code
        )
    ],
);
@EXPORT_TAGS{'storage'} = [
    @{ $EXPORT_TAGS{'registers'} },
    @{ $EXPORT_TAGS{'memory'} },
];
@EXPORT_TAGS{'all'} = [
    @{ $EXPORT_TAGS{'storage'} },
    @{ $EXPORT_TAGS{'flag_control'} },
];

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.19.02';

our %process_registers = (
    F => 0, # flags register [NV-BDIZC]
    C => 0, # program code pointer
    S => 0, # stack pointer, not used as yet
    I => 0, # data pointer, base value for indexed mode access
    A => 0, # accumulator
    X => 0, # X register
    D => 0, # data register, used as the second value for math ops
);
our %status_flags = ( # bitmap masks for contents of F register $reg{F};
    N => 1 << 7,  # Negative
    V => 1 << 6,  # Overflow (Not implemented here)
    X => 1 << 5,  # Ignored
    B => 1 << 4,  # Break
    D => 1 << 3,  # Decimal (Not implemented here)
    I => 1 << 2,  # Interrupt
    Z => 1 << 1,  # Zero
    C => 1 << 0,  # Carry (Not implemented here)
);
our @stack_heap = (); # the stack for the computer
our @core_ram = (); # the complete memory of the computer
our %address_mode = (
    accumulator => 1, # (I) No operand, implied accumulator
    absolute    => 0, # (A) Data address is the operand
                      #     Jump target is the opcode
    indexed     => 2, # (X) Data address is I-register plus operand
                      #     Jump target is I-register plus (signed) operand 
    direct      => 1, # (I) Operand is the data itself, not an address (not used in write)
    immediate   => 1, # (I) Operand is the data itself, not an address (not used in write)
                      #     Jump target is signed offset from C-register (after stepping)
    implied     => 1, # (I) No operand, implied by the instruction
    indirect    => 3, # (P) The operand is a pointer to the address; operand -> memory -> data
    pointer     => 3, # (P) The operand is a pointer to the address; operand -> memory -> data
                      #     Jump target is the data at address operand
    reference   => 4, # (R) The operand is an indexed pointer to the address [I + operand] -> memory -> data
    relative    => 5, # (R) The operand is a signed offset from C-register (after stepping)
                      #     Jump target is the data at address I-register plus (signed) operand
    list        => 6, # (L) The operand is the pointer to a list, I-register is index into the list
);
our @program_code = (); # the executable section of memory


1;
__END__

=head1 NAME

IntCode::AsmComp::Internals

=head1 SYNOPSIS

  use IntCode::AsmComp::Internals;

=head1 DESCRIPTION

Implementation of the low-level architecture of the IntCode computer
needed by the elves in the 2019 Advent of Code challenges.

=head2 EXPORT

        %process_registers
        %status_flags
        %address_mode
        @stack_heap
        @core_ram
        @program_code

=head1 AUTHOR

Chindraba, E<lt>aoc@chindraba.workE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright © 2019, 2020  Chindraba (Ronald Lamoreaux)
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
