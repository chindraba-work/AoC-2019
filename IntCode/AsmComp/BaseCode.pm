package IntCode::AsmComp::BaseCode;

# SPDX-License-Identifier: MIT

use 5.026001;
use strict;
use warnings;
use IntCode::AsmComp::Internals;

use Data::Dumper qw/Dumper/;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
	%registers
	system_register
	%flags
	system_flag 
	system_stack
	%addressing
	system_memory
	program_init
	program_length
	program_next_code
	program_set_address
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.19.02';

# Structure and routines to handle the system registers
our %register = (
    Accumulator    => 'A', # accumulator
    CodePointer    => 'C', # program code pointer
    IndexPointer   => 'I', # data pointer, base value for indexed mode access
    StackPointer   => 'S', # stack pointer, not used as yet
    StatusRegister => 'F', # flags register [NV-BDIZC]
    X_Register     => 'X', # X register
    DataRegister   => 'D', # data register, used as the second value for math ops
);

sub base_load_register {
    $process_registers{$_[0]} = $_[1];
    return $process_registers{$_[0]};
}

sub base_read_register {
    return $process_registers{$_[0]};
}

sub base_dump_registers {
    say "\nRegister Contents:";
    map {
        printf("'%s' => %2\$064b: %i\n", $_, $process_registers{$_});
    } qw(C S I A X);
    printf("'F' => %08b\n", $process_registers{F});
}

# Exported routine for access to system registers
sub system_register{
# No arguments is report all register contents
# One argument is read the register,
# two arguments is load the register,
# Return is the new/current value of the register
# Arg 1 is the register to access,
# Arg 2 is the data to save there.
    if ( 0 == @_ ) {
        base_dump_registers();
    } elsif ( 1 == @_ ) {
        return base_read_register($_[0]);
    } elsif ( 2 == @_ ) {
        return base_load_register($_[0], $_[1]);
    }
    return undef;
}

# Structure and routines to handle the system status flags
our %flags = (
    Negative  => 'N', # Negative
    Overflow  => 'V', # Overflow (Not implemented here)
    Break     => 'B', # Break
    Decimal   => 'D', # Decimal (Not implemented here)
    Interrupt => 'I', # Interrupt
    Zero      => 'Z', # Zero
    Carry     => 'C', # Carry (Not implemented here)
);

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

sub base_read_flag {
    return $process_registers{F} & $status_flags{$_[0]} ? 1 : 0;
}

sub base_dump_flags {
    say "\nFlag Status:";
    map {
        printf("Flag %s is %s\n", $_, ($process_registers{F} & $status_flags{$_})? 'Set' : 'Clear');
    } qw(N V B D I Z C);
    return 1;
}

# Exported routine for access to the system status flags
sub system_flag {
# Routine to read/set/clear the flags of the status register.
#   No args is a dump of the status flags
#       Only Negative and Zero do any testing, other wise it
#       results in a call to set the flag based on true/false of value
#   One arg is read flag
#   Two arg is set flag
#   Three arg set/clear flag on test of value
# Arg 1: Flag (NVBDIZC)
# Arg 2: ignored if 3rd arg is present, use undef for clarity
#        1 set flag
#        0 clear flag
#        undef clear flag
# Arg 3: The value to test. Only applies to N and Z, other flags
#        will toggle, regardless of the value, if the 2nd arg is defined
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

# Routines to handle the system stack
# The @stack_heap array is used for the stack of the system, but the 
# push and pull operations are handled manually using the stack pointer
# register of the system rather than the Perl array functionality.
# The stack pointer is dual-purpose: the number of elements in the list
# and the index of the next element to add to the list.
sub base_push_stack {
    return $stack_heap[$process_registers{S}++] = $_[0];
}

sub base_pull_stack {
    if ( 0 == $process_registers{S} ) {
        return undef;
    }
    return $stack_heap[--$process_registers{S}];
}

sub base_dump_stack {
    say("Stack dump: ", join ', ', (@stack_heap[0..$process_registers{S} - 1]));
    return undef;
}

# Exported routine for access to the system stack
sub system_stack {
# Routine to access the system stack
# No arguments is pull
# One argument is push
# Special case of one arg is 'dump' which triggers a dump of the stack
#   There is no functionality to push multiple values to "pre-load" the
# stack, it must be pushed one item at a time.
    if ( 0 == @_ ) {
        return base_pull_stack();
    } elsif ( 'dump' eq $_[0] ) {
        return base_dump_stack();
    }
    return base_push_stack($_[0]);
}

# Translation hash to provide convenient names to the address modes for
# memory addressing and for branch/jump targets in the Asm codes
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

# Routines to handle the system memory
sub base_load_memory {
    @core_ram = @_;
}

sub base_write_memory {
# Routine to write memory using the supplied operand and given address mode
#   Arg 1 is Address mode
#   Arg_2 is operand
#   Arg_3 is the data to write
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

sub base_read_memory {
# Routine to read memory using the supplied operand and given address mode
#   Arg 1 is Address mode
#   Arg_2 is operand
#   Return is the resolved value
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

sub base_dump_memory {
    my $memory_dump = join(', ', (@core_ram));
    say("Memory dump: $memory_dump");
}

# Exported routine for access the system memory
sub system_memory {
# Two arg version reads memory
# Three arg version writes memory
# List longer than 3 args is dumped into memory raw, initialize it
# Arg 1: memory address mode
# Arg 2: memory address, will be modified as per address mode
# Arg 3: if present, the data to write to memory
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

# Routines to handle the code segment access
sub base_load_code {
    @program_code = @_;
}

sub base_code_address { 
# Routine to find the desired code address using the supplied operand
# and given address mode
#   Arg 1 is Address mode
#   Arg_2 is operand
#   Return is the resolved value
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

sub base_next_code {
# Return the item from the program_code at the code_pointer address
# Increment the code_pointer
    return $program_code[$process_registers{C}++];
}

# Exported routine for access to the program code
sub program_length {
# Routine to return the number of codes in the program
    return scalar @program_code;
}

sub program_next_code {
# Routine to get the next instruction, or operand from the code
# and increment the code pointer
    return base_next_code();
}

sub program_set_address {
# Routine to change the code pointer for a branch or jump
#   Arg 1: address mode to use
#   Arg 2: the operand to apply
    $process_registers{C} = base_code_address(@_) if ( 2 == @_ );
}

sub program_init {
# Routine to load the program into memory
# copies the arg list into the program code memory and reset the code
# pointer
    base_load_code(@_);
    $process_registers{C} = 0;
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

=head2 EXPORT

	%registers
	system_register
	%flags
	system_flag 
	system_stack
	%addressing
	system_memory
	program_init
	program_length
	program_next_code
	program_set_address

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
