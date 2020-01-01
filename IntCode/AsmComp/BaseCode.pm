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
    system_stack
	system_memory
	system_register
	system_flag 
    %addressing
    %flags
    %registers
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.01.02';

# Data structures for providing "names" for the address modes, 
# registers, and flags.
our %addressing = (
    Absolute    => 0,
    Accumulator => 1,
    Direct      => 1,
    Indexed     => 2,
    Immediate   => 1,
    Implied     => 1,
    Indirect    => 3,
    Pointer     => 3,
    Reference   => 4,
    Relative    => 4,
);

our %registers = (
    Accumulator    => 'A',
    CodePointer    => 'C',
    IndexPointer   => 'I',
    StackPointer   => 'S',
    StatusRegister => 'F',
    X_Register     => 'X',
);

our %flags = (
    Break     => 'B',
    Carry     => 'C',
    Decimal   => 'D',
    Interrupt => 'I',
    Negative  => 'N',
    Overflow  => 'V',
    Zero      => 'Z',
);

# Internal routines for handling status flag access
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
        base_set_flag $_[0], $_[1];
    }
}

sub base_dump_flags {
    say "\nFlag Status:";
    map {
        printf "Flag %s is %s\n", $_, ($process_registers{F} & $status_flags{$_})? 'Set' : 'Clear';
    } qw(N V B D I Z C);
    return 1;
}

# Internal routines for handling the system register access
sub base_read_register {
    return $process_registers{$_[0]};
}

sub base_load_register {
    $process_registers{$_[0]} = $_[1];
    return $process_registers{$_[0]};
}

sub base_dump_registers {
    say "\nRegister Contents:";
    map {
        printf "'%s' => %2\$064b: %i\n", $_, $process_registers{$_};
    } qw(C S I A X);
    printf "'F' => %08b\n", $process_registers{F};
}

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
    say "Stack dump: ", join ', ', (@stack_heap);
    return undef;
}

# Internal routines for handling memory access
sub base_read_memory {
# Routine to read memory using the supplied operand and given address mode
#   Arg 1 is Address mode
#   Arg_2 is operand
#   Return is the resolved value
    my ($addr_mode, $operand) = @_;
    if ($addr_mode == $address_mode{relative} ) {
        return $operand + $process_registers{S};
    } elsif ($addr_mode == $address_mode{absolute} ) {
        return $core_ram[$operand];
    } elsif ($addr_mode == $address_mode{indexed} ) {
        return $core_ram[$process_registers{I} + $operand];
    } elsif ($addr_mode == $address_mode{pointer} ) {
        return $core_ram[$core_ram[$operand]];
    } elsif ($addr_mode == $address_mode{reference} ) {
        return $core_ram[$core_ram[$process_registers{I} + $operand]];
    } else {
        return $operand;
    }
}

sub base_write_memory {
# Routine to write memory using the supplied operand and given address mode
#   Arg 1 is Address mode
#   Arg_2 is operand
#   Arg_3 is the data to write
    my ($addr_mode, $operand, $data) = @_;
    if ($addr_mode == $address_mode{absolute} ) {
        $core_ram[$operand] = $data;
    } elsif ($addr_mode == $address_mode{indexed} ) {
        $core_ram[$process_registers{I} + $operand] = $data;
    } elsif ($addr_mode == $address_mode{pointer} ) {
        $core_ram[$core_ram[$operand]] = $data;
    } elsif ($addr_mode == $address_mode{reference} ) {
        $core_ram[$core_ram[$process_registers{I} + $operand]] = $data;
    } else {
        return undef;
    }
    return 1;
}

# Exportable routines for access to system internals
# Wrapper routines for the internal routines
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
        base_dump_flags;
        return 1;
    } elsif ( 1 == @_ ) {
        return base_read_flag $_[0];
    } elsif ( 2 == @_ ) {
        base_set_flag $_[0], $_[1];
        return base_read_flag $_[0];
    } elsif ( 3 == @_) {
        base_test_flag $_[0], $_[2];
        return base_read_flag $_[0];
    }
}

sub system_register{
# Routine to access the system registers
# No arguments is report all register contents
# One argument is read the register,
# two arguments is load the register,
# Return is the new/current value of the register
# Arg 1 is the register to access,
# Arg 2 is the data to save there.
    if ( 0 == @_ ) {
        base_dump_registers;
    } elsif ( 1 == @_ ) {
        return base_read_register $_[0];
    } elsif ( 2 == @_ ) {
        return base_load_register $_[0], $_[1];
    }
    return undef;
}

# Routine to access the system stack
# No arguments is pull
# One argument is push
# Special case of one arg is 'dump' which triggers a dump of the stack
sub system_stack {
    if ( 0 == @_ ) {
        return base_pull_stack;
    } elsif ( 'dump' eq $_[0] ) {
        return base_dump_stack;
    }
    return base_push_stack $_[0];
}

sub system_memory {
# Routine to access the system memory
# Two arg version reads memory
# Three arg version writes memory
# List longer than 3 args is dumped into memory raw, initialize it
# Arg 1: memory address mode
# Arg 2: memory address, will be modified as per address mode
# Arg 3: if present, the data to write to memory
    if ( 0 == @_ ) {
        my $memory_dump = join ', ', (@core_ram);
        say "Memory dump: $memory_dump";
    } elsif ( 3 < @_ ) {
        @core_ram = @_;
    } elsif ( 3 == @_ ) {
        return base_write_memory( @_ );
    } elsif ( 2 == @_ ) {
        return base_read_memory( @_ );
    } else {
        die "Attempt to access memory with invalid parameter(s): '", join("', '", (@_)),"'\n";
    }
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
