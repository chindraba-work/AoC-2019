package IntCode::AsmComp::OpCodes;

# SPDX-License-Identifier: MIT

use 5.026001;
use strict;
use warnings;
use IntCode::AsmComp::BaseCode;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'op_codes' => [ qw(
    load_memory
    run_snippet
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'op_codes'} } );

our @EXPORT = ( @{ $EXPORT_TAGS{'op_codes'} } );

our $VERSION = '0.01.02';

my @snippet;
my $access_mode;
my $operand;

sub get_memory {
    $access_mode = shift @snippet;
    $operand = shift @snippet;
    return system_memory $access_mode, $operand;
}

sub set_memory {
    system_memory $access_mode, $operand, $_[0];
}

sub flag_test {
    system_flag('N', undef, $_[0]);
    system_flag('Z', undef, $_[0]);
}

sub branch {
    system_register('C', 2 + (system_register 'C') + $_[2])
        if ( $_[0] == system_flag $_[1] );
}

sub copy_register {
    system_register $_[1], system_register $_[0];
    flag_test(system_register $_[1])
        if $_[2];
}

sub core_dump {
    system_memory;
    system_stack 'dump';
    system_register;
    system_flag;
}

sub load_register {
    system_register $_[0], get_memory;
    flag_test(system_register $_[0])
        if $_[1];
}

sub store_register {
    $access_mode = shift @snippet;
    $operand = shift @snippet;
    set_memory system_register($_[0]);
}

# Routines to implement the Opcodes in a common manner
my %opcode = (
    ADC => sub {
        system_register 'A', (system_register 'A') + get_memory;
        flag_test(system_register 'A');
    },
    AND => sub {
        system_register 'A', (system_register 'A') & get_memory;
        flag_test(system_register 'A');
    },
    ASL => sub {
        system_register 'D', get_memory;
        system_flag 'C', undef, (system_register 'D') & (~0^~0>>1);
        system_register 'D', (system_register 'D') << 1;
        set_memory system_register 'D';
        flag_test(system_register 'D');
    },
    ASR => sub {
        my $value = get_memory;
        system_register 'D', $value & (~0^~0>>1);
        set_memory( (system_register 'D') | ($value >> 1));
        flag_test(system_memory $access_mode, $operand);
    },
    BCC => sub { branch(0, 'C', @_); },
    BCS => sub { branch(1, 'C', @_); },
    BEQ => sub { branch(1, 'Z', @_); },
    BIT => sub {
        system_register 'D', get_memory;
        system_flag 'N', undef, system_register 'D';
        system_register 'D', (system_register 'D') & system_register 'A';
        system_flag 'Z', undef, system_register 'D';
    },
    BMI => sub { branch(1, 'N', get_memory); },
    BNE => sub { branch(0, 'Z', get_memory); },
    BPL => sub { branch(0, 'N', get_memory); },
    BRK => sub {
        system_flag 'I', 1;
        system_stack 2 + system_register 'C';
        system_stack system_register 'F';
        system_memory;
        system_stack 'dump';
        system_register;
        system_flag;
        exit;
    },
    BVC => sub { branch(0, 'V', get_memory); },
    BVS => sub { branch(1, 'V', get_memory); },
    CLC => sub { system_flag 'C', 0; },
    CLD => sub { system_flag 'D', 0; },
    CLI => sub { system_flag 'I', 0; },
    CLV => sub { system_flag 'V', 0; },
    CMP => sub {
        system_register 'D', (system_register 'A') - get_memory;
        flag_test(system_register 'D');
    },
    CPX => sub {
        system_register 'D', (system_register 'X') - get_memory;
        flag_test(system_register 'D');
    },
    DEC => sub {
        my $value = get_memory;
        system_memory $access_mode, $operand, -1 + $value;
        flag_test(system_memory $access_mode, $operand);
    },
    DEX => sub {
        system_register 'X', -1 + system_register 'X';
        flag_test(system_register 'X');
    },
    EOR => sub {
        system_register 'A', (system_register 'A') ^ get_memory;
        flag_test(system_register 'A');
    },
    INC => sub {
        my $value = get_memory;
        system_memory $access_mode, $operand, 1 + $value;
        flag_test(system_memory $access_mode, $operand);
    },
    INP => sub {
        get_memory;
        system_register 'D', shift @ARGV
            || die "Data expected but not found on command line.";
        flag_test(system_register 'D');
        if ( $access_mode == $addressing{Accumulator} ) {
            system_register 'A', system_register 'D';
        } else {
            system_memory $access_mode, $operand, system_register 'D';
        }
    },
    INX => sub {
        system_register 'X', 1 + system_register 'X';
        flag_test(system_register 'X');
    },
    JMP => sub { system_register 'C', get_memory; },
    JSR => sub {
        system_stack 2 + system_register 'C';
        system_register 'C', get_memory;
    },
    LDA => sub { load_register('A', 1); },
    LDF => sub { load_register('F'); },
    LDI => sub { load_register('I', 1); },
    LDS => sub { load_register('S', 1); },
    LDX => sub { load_register('X', 1); },
    LSR => sub {
        set_memory(get_memory >> 1);
        flag_test(system_memory $access_mode, $operand);
    },
    MUL => sub {
        system_register 'A', (system_register 'A') * get_memory;
        flag_test(system_register 'A');
    },
    ORA => sub {
        system_register 'A', (system_register 'A') | get_memory;
        flag_test(system_register 'A');
    },
    OUT => sub {
        system_register 'D', get_memory;
        printf "Program output: %1\$016b: %1\$u, (%1\$d)\n", system_register 'D';
    },
    PHA => sub { system_stack system_register 'A'; },
    PHP => sub { system_stack system_register 'F'; },
    PLA => sub { 
        system_register 'A', system_stack;
        flag_test(system_register 'A');
    },
    PLP => sub { system_register 'F', system_stack; },
    ROL => sub {
        my $value = get_memory;
        system_flag 'C', undef, $value & (~0^~0>>1);
        set_memory(($value << 1) + system_flag 'C');
        flag_test(system_memory $access_mode, $operand);
    },
    ROR => sub {
        my $value = get_memory;
        system_flag 'C', undef, $value & 1;
        if ( system_flag 'C' ) {
            set_memory(($value >> 1) | (~0^~0>>1));
        } else {
            set_memory $value >> 1;
        }
        flag_test(system_memory $access_mode, $operand);
    },
    RTI => sub {
        system_register 'F', system_stack;
        system_register 'C', system_stack;
    },
    RTS => sub { system_register 'C', system_stack; },
    SBC => sub {
        system_register 'A', (system_register 'A') - get_memory;
        map {
            system_flag($_, undef, system_register('A'));
        } qw(N V Z C);
    },
    SEC => sub { system_flag('C', 1); },
    SED => sub { system_flag('D', 1); },
    SEI => sub { system_flag('I', 1); },
    STA => sub { store_register 'A'; },
    STI => sub { store_register 'I'; },
    STX => sub { store_register 'X'; },
    TAI => sub { copy_register 'A', 'I', 1; },
    TAX => sub { copy_register 'A', 'X', 1; },
    TIA => sub { copy_register 'I', 'A'; },
    TIX => sub { copy_register 'I', 'X'; },
    TSX => sub { copy_register 'S', 'X', 1; },
    TXA => sub { copy_register 'X', 'I', 1; },
    TXI => sub { copy_register 'X', 'I'; },
    TXS => sub { copy_register 'X', 'S'; },
);

$opcode{DIV} = sub {
    my $value = get_memory;
    if ( 0 == $value ) {
        system_flag('Z', 1);
        system_flag('V', 1);
        system_flag('B', 1);
        $opcode{BRK}();
    }
    system_register 'X', (system_register 'A') % $value;
    system_register 'A', int((system_register 'A') / $value);
    flag_test system_register 'A';
};

sub load_memory {
    system_memory( @_, 0, 0, 0 );
};

sub run_snippet {
    @snippet = @_;
    while ( @snippet && ! system_flag('B') ) {
say "Doing $snippet[0]";
        $opcode{shift @snippet}();
    }
}

1;
__END__

=head1 NAME

IntCode::AsmComp::OpCodes

=head1 SYNOPSIS

  use IntCode::AsmComp::OpCodes;

=head1 DESCRIPTION

Implementation of the low-level workings of the IntCode computer needed
by the elves in the 2019 Advent of Code challenges.

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
