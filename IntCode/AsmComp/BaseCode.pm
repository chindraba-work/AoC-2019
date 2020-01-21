package IntCode::AsmComp::BaseCode;

# SPDX-License-Identifier: MIT

use 5.026001;
use strict;
use warnings;
use IntCode::AsmComp::Internals;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
    %addressing
    %flags
    %registers
    program_init
    program_length
    program_next_code
    program_set_address
    system_flag 
    system_memory
    system_register
    system_stack
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.19.07';

our %addressing = (
    Absolute    => $address_mode{absolute},     # (A) Data address is the operand
                                                #     Jump target is the opcode
    Accumulator => $address_mode{accumulator},  # (I) No operand, implied accumulator
    Direct      => $address_mode{direct},       # (I) Operand is the data itself, not an address (not used in write)
    Indexed     => $address_mode{indexed},      # (X) Data address is I-register plus operand
                                                #     Jump target is I-register plus (signed) operand 
    Immediate   => $address_mode{immediate},    # (I) Operand is the data itself, not an address (not used in write)
                                                #     Jump target is signed offset from C-register (after stepping)
    Implied     => $address_mode{implied},      # (I) No operand, implied by the instruction
    Indirect    => $address_mode{indirect},     # (P) The operand is a pointer to the address; operand -> memory -> data
    List        => $address_mode{list},         # (L) The operand is the pointer to a list, I-register is index into the list
    Pointer     => $address_mode{pointer},      # (P) The operand is a pointer to the address; operand -> memory -> data
                                                #     Jump target is the data at address operand
    Reference   => $address_mode{reference},    # (R) The operand is an indexed pointer to the address [I + operand] -> memory -> data
    Relative    => $address_mode{relative},     # (R) The operand is a signed offset from C-register (after stepping)
);                                              #     Jump target is the data at address I-register plus (signed) operand

our %flags = (
    Negative  => 'N', # Negative
    Overflow  => 'V', # Overflow (Not implemented here)
    Expose    => 'X', # Expose signal to API
    Break     => 'B', # Break
    Decimal   => 'D', # Decimal (Repurposed as signal to dump core on BRK/STP)
    Interrupt => 'I', # Interrupt
    Zero      => 'Z', # Zero
    Carry     => 'C', # Carry (Not implemented here)
);

our %register = (
    Accumulator    => 'A', # accumulator
    CodePointer    => 'C', # program code pointer
    IndexPointer   => 'I', # data pointer, base value for indexed mode access
    StackPointer   => 'S', # stack pointer, not used as yet
    StatusRegister => 'F', # flags register [NV-BDIZC]
    X_Register     => 'X', # X register
    DataRegister   => 'D', # data register, used as the second value for math ops
                           # and as return value to API for external processing
);

sub base_dump_registers {
    say "\nRegister Contents:";
    map {
        printf("'%s' => %2\$064b: %i\n", $_, $process_registers{$_});
    } qw(C S I A X);
    printf("'F' => %08b\n", $process_registers{F});
}

sub base_load_register {
    $process_registers{$_[0]} = $_[1];
    return $process_registers{$_[0]};
}

sub base_read_register {
    return $process_registers{$_[0]};
}

sub base_dump_flags {
    say "\nFlag Status:";
    map {
        printf("Flag %s is %s\n", $_, ($process_registers{F} & $status_flags{$_})? 'Set' : 'Clear');
    } qw(N V B D I Z C);
    return 1;
}

sub base_read_flag {
    return $process_registers{F} & $status_flags{$_[0]} ? 1 : 0;
}

sub base_set_flag {
    if ( 0 == $_[1] ) {
        $process_registers{F} &=  ~$status_flags{$_[0]};
    } else {
        $process_registers{F} |=  $status_flags{$_[0]};
    }
}

sub base_test_flag {
    if ( 'N' eq $_[0] ) {
        if ( $_[1] == abs($_[1]) ) {
            $process_registers{F} &= ~$status_flags{N};
        } else {
            $process_registers{F} |=  $status_flags{N};
        }
    } elsif ( 'Z' eq $_[0] ) {
        if ( 0 == $_[1]) {
            $process_registers{F} |=  $status_flags{Z};
        } else {
            $process_registers{F} &= ~$status_flags{Z};
        }
    } else {
        base_set_flag($_[0], $_[1]);
    }
}

sub base_dump_stack {
    say("Stack dump: ", join ', ', (@stack_heap[0..$process_registers{S} - 1]));
    return undef;
}

sub base_pull_stack {
    if ( 0 == $process_registers{S} ) {
        return undef;
    }
    return $stack_heap[--$process_registers{S}];
}

sub base_push_stack {
    return $stack_heap[$process_registers{S}++] = $_[0];
}

sub base_dump_memory {
    my $memory_dump = join(', ', (@core_ram));
    say("Memory dump: $memory_dump");
}

sub base_load_memory {
    @core_ram = @_;
}

sub base_read_memory {
    my ($addr_mode, $operand) = @_;
    if ($addr_mode == $addressing{Absolute} ) {
        return $core_ram[$operand];
    } elsif ($addr_mode == $addressing{Indexed} ) {
        return $core_ram[$process_registers{I} + $operand];
    } elsif ($addr_mode == $addressing{List} ) {
        return $core_ram[$process_registers{I} + $core_ram[$operand]];
    } elsif ($addr_mode == $addressing{Pointer} ) {
        return $core_ram[$core_ram[$operand]];
    } elsif ($addr_mode == $addressing{Reference} ) {
        return $core_ram[$core_ram[$process_registers{I} + $operand]];
    } else {
        return $operand;
    }
}

sub base_write_memory {
    my ($addr_mode, $operand, $data) = @_;
    if ($addr_mode == $addressing{Absolute} ) {
        $core_ram[$operand] = $data;
    } elsif ($addr_mode == $addressing{Indexed} ) {
        $core_ram[$process_registers{I} + $operand] = $data;
    } elsif ($addr_mode == $addressing{List} ) {
        $core_ram[$process_registers{I} + $core_ram[$operand]] = $data;
    } elsif ($addr_mode == $addressing{Pointer} ) {
        $core_ram[$core_ram[$operand]] = $data;
    } elsif ($addr_mode == $addressing{Reference} ) {
        $core_ram[$core_ram[$process_registers{I} + $operand]] = $data;
    } else {
        return undef;
    }
    return 1;
}

sub base_code_address { 
    my ($addr_mode, $operand) = @_;
    if ( $addr_mode == $addressing{Immediate} ) {
        return $process_registers{C} + $operand;
    } elsif ($addr_mode == $addressing{Indexed} ) {
        return $process_registers{I} + $operand;
    } elsif ($addr_mode == $addressing{List} ) {
        return $process_registers{I} + $core_ram[$operand];
    } elsif ($addr_mode == $addressing{Indirect} ) {
        return $core_ram[$operand];
    } elsif ($addr_mode == $addressing{Relative} ) {
        return $process_registers{C} + $operand;
    } else {
        return $operand;
    }
}

sub base_load_code {
    @program_code = @_;
}

sub base_next_code {
    return $program_code[$process_registers{C}++];
}

sub program_init {
    base_load_code(@_);
    $process_registers{C} = 0;
}

sub program_length {
    return scalar @program_code;
}

sub program_next_code {
    return base_next_code();
}

sub program_set_address {
    $process_registers{C} = base_code_address(@_) if ( 2 == @_ );
}

sub system_flag {
    if ( 0 == @_ ) {
        base_dump_flags();
        return 1;
    } elsif ( 1 == @_ ) {
        return base_read_flag($_[0]);
    } elsif ( 2 == @_ ) {
        base_set_flag($_[0], $_[1]);
        return base_read_flag($_[0]);
    } elsif ( 3 == @_) {
        base_test_flag($_[0], $_[2]);
        return base_read_flag($_[0]);
    }
}

sub system_memory {
    if ( 0 == @_ ) {
        base_dump_memory();
    } elsif ( 3 < @_ ) {
        base_load_memory(@_);
    } elsif ( 3 == @_ ) {
        return base_write_memory( @_ );
    } elsif ( 2 == @_ ) {
        return base_read_memory( @_ );
    }
    return undef;
}

sub system_register{
    if ( 0 == @_ ) {
        base_dump_registers();
    } elsif ( 1 == @_ ) {
        return base_read_register($_[0]);
    } elsif ( 2 == @_ ) {
        return base_load_register($_[0], $_[1]);
    }
    return undef;
}

sub system_stack {
    if ( 0 == @_ ) {
        return base_pull_stack();
    } elsif ( 'dump' eq $_[0] ) {
        return base_dump_stack();
    }
    return base_push_stack($_[0]);
}

1;
__END__

=head1 NAME

IntCode::AsmComp::BaseCode

=head1 SYNOPSIS

  use IntCode::AsmComp::BaseCode;

=head1 DESCRIPTION

Implementation of the low-level functionality of the IntCode computer
needed by the elves in the 2019 Advent of Code challenges.

Exported variables and routines are:
    %addressing
        A hash to convert capitalized textual names for address modes
            to numerical value for address mode in the internal scheme.
    %flags
        A hash to convert textual names into flag names for use by the
            system_flag routine.
    %registers
        A hash to convert textual names into register names for use by
            the system_register routine.
    program_init(list of program code)
        Routine to load the code segment with commands and reset the
            code pointer
        Return value: none
    program_length()
        Return value: the length of the occupied code segment
    program_next_code()
        Routine to read the next command in code segment and increment
            the code pointer
        Return value: contents of the code segment addressed by the
            code pointer.
    program_set_address(address_mode,address_base)
        Routine to change the code pointer to the address as resolved
            by the two arguments, using the same system as normally
            used for resolving address in memory.
        Return value: none
    system_flag([{N|V|B|D|I|Z|C}[,{0|1}]])
        Routine to access the system flags 
            No arguments is report all flag settings, printed to the
                live terminal, breaks encapsulation
            One argument is read the flag,
            Two arguments is set/clear the flag,
                Arg 1 is the flag to access,
                Arg 2 is the set/clear, (1/0) to save there.
        Return value: the new/current setting of the flag, or undef for
            either the dump or argument arguments <> 1..2
    system_memory([{0|1|2|3|4|5|6},address[,value]]|[list of memory values])
        Routine to access the system memory
            Arg 1 is the address mode, expecting integer values only
            Arg 2 is the base address, which may be modified by the
                address mode of Arg 1
            Arg 3 is the data to place into the resolved address
            No arguments causes a dump of the system memory (core_ram)
                to the live terminal, breaks encapsulation
            Two arguments reads the memory as resolved by the first and
                second arguments.
            Three arguments places the third argument into the memory
                as resolved by the first and second arguments.
            More than three arguments is understood to me the complete
                list of what should be in memory, and is copied raw
                into memory, overwriting anything already there.
        Return value: the current/new value of the memory as resolved
            by the first two arguments, or undef for a dump or load
            operation.
    system_register([{A|C|I|P|S|F|X|D}[,register_value]])
        Routine to access the system registers
            No arguments is report all register contents, printed to
                the live terminal, breaks encapsulation
            One argument is read the register,
            Two arguments is load the register,
                Arg 1 is the register to access,
                Arg 2 is the data to save there.
        Return value: the new/current value of the register, or undef
            for either the dump or argument arguments <> 1..2
    system_stack([new_value|'dump'])
        Routine to access the system stack
            No arguments does a pull from the stack, returning the
                pulled value and decrementing the stack pointer
            One argument, not the word 'dump', pushes the argument onto
                the stack and increments the stack pointer, and returns
                the result of the push.
            The word 'dump' as the single argument causes a dump of the
                stack to the live terminal, breaks encapsulation
        Return value: the value pulled, or the return from the push or
            dump operation.

=head2 EXPORT

    %addressing
    %flags
    %registers
    program_init
    program_length
    program_next_code
    program_set_address
    system_flag 
    system_memory
    system_register
    system_stack

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
