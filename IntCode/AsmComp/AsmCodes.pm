package IntCode::AsmComp::AsmCodes;

# SPDX-License-Identifier: MIT

use 5.026001;
use strict;
use warnings;
use IntCode::AsmComp::BaseCode;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
	program_load
	memory_load
	direct_memory_access
	program_resume
	program_run
	program_step
	one_shot
	soft_start
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.19.07';

my $access_mode;
my $operand;

*program_load = *IntCode::AsmComp::BaseCode::program_init;

sub set_operand {
    $access_mode = $addressing{program_next_code()};
    $operand = program_next_code();
}

sub flag_test {
    system_flag('N', undef, $_[0]);
    system_flag('Z', undef, $_[0]);
}

sub register_check {
    flag_test(system_register($_[0]));
}

sub load_memory {
    system_memory(@_);
};

sub set_memory {
    system_memory($access_mode, $operand, $_[0]);
}

sub get_memory {
    return system_memory($access_mode, $operand);
}

sub direct_memory_access {
    system_memory($addressing{Absolute}, $_[0], $_[1])
        if ( 2 == @_ );
    return system_memory($addressing{Absolute}, $_[0]);
}

sub memory_check {
    flag_test(system_memory($access_mode, $operand));
}

sub copy_register {
    system_register($_[1], system_register($_[0]));
    register_check($_[1])
        if ( $_[2] );
}

sub load_register {
    set_operand();
    system_register($_[0], get_memory());
    register_check($_[0])
        if ( $_[1] );
}

sub store_register {
    set_operand();
    set_memory(system_register($_[0]));
}

sub branch {
    set_operand();
    program_set_address($access_mode, $operand)
        if ( $_[0] == system_flag($_[1]) );
}

sub core_dump {
    system_memory();
    system_stack('dump');
    system_register();
    system_flag();
}

# Routines to implement the assembly codes in a common manner
my %asmcode = (
    ABT => sub { core_dump(); exit; },
    ADC => sub {
        set_operand();
        system_register('A', system_register('A') + get_memory());
        register_check('A');
    },
    AND => sub {
        set_operand();
        system_register('A', system_register('A') & get_memory());
        register_check('A');
    },
    ASL => sub {
        set_operand();
        system_register('D', get_memory());
        system_flag('C', undef, system_register('D') & (~0^~0>>1));
        system_register('D', system_register('D') << 1);
        set_memory(system_register('D'));
        register_check('D');
    },
    ASR => sub {
        set_operand(); 
        my $value = get_memory();
        system_register('D', $value & (~0^~0>>1));
        set_memory(system_register('D') | ($value >> 1));
        memory_check();
    },
    BCC => sub { branch(0, 'C'); },
    BCS => sub { branch(1, 'C'); },
    BEQ => sub { branch(1, 'Z'); },
    BIT => sub {
        set_operand();
        system_register('D', get_memory());
        system_flag('N', undef, system_register('D'));
        system_register('D', system_register('D') & system_register('A'));
        system_flag('Z', undef, system_register('D'));
    },
    BMI => sub { branch(1, 'N'); },
    BNE => sub { branch(0, 'Z'); },
    BPL => sub { branch(0, 'N'); },
    BRK => sub {
        program_next_code();
        system_stack(system_register('C'));
        system_stack(system_register('F'));
        system_flag('I', 1);
        core_dump()
            if ( system_flag('D') );
    },
    BVC => sub { branch(0, 'V'); },
    BVS => sub { branch(1, 'V'); },
    CLC => sub { system_flag('C', 0); },
    CLD => sub { system_flag('D', 0); },
    CLI => sub { system_flag('I', 0); },
    CLV => sub { system_flag('V', 0); },
    CLX => sub { system_flag('X', 0); },
    CMP => sub {
        set_operand();
        system_register('D', system_register('A') - get_memory());
        register_check('D');
    },
    CPX => sub {
        set_operand();
        system_register('D', system_register('X') - get_memory());
        register_check('D');
    },
    DEC => sub {
        set_operand();
        my $value = get_memory();
        system_memory($access_mode, $operand, $value - 1);
        memory_check();
    },
    DEI => sub {
        system_register('I', system_register('I') - 1);
        register_check('I');
    },
    DEX => sub {
        system_register('X', system_register('X') - 1);
        register_check('X');
    },
    EOR => sub {
        set_operand();
        system_register('A', system_register('A') ^ get_memory());
        register_check('A');
    },
    GET => sub {
        set_operand();
        while ( 0 == @ARGV ) {
            sleep 1;
        }
        system_register('D', shift(@ARGV));
        register_check('D');
        if ( $access_mode == $addressing{Accumulator} ) {
            system_register('A', system_register('D'));
        } else {
            system_memory($access_mode, $operand, system_register('D'));
        }
    },
    INC => sub {
        set_operand();
        my $value = get_memory();
        system_memory($access_mode, $operand, $value + 1);
        memory_check();
    },
    INP => sub {
        set_operand();
        system_register('D', shift(@ARGV))
            || die "Data expected but not found on command line.";
        register_check('D');
        if ( $access_mode == $addressing{Accumulator} ) {
            system_register('A', system_register('D'));
        } else {
            system_memory($access_mode, $operand, system_register('D'));
        }
    },
    INI => sub {
        system_register('I', system_register('I') + 1);
        register_check('I');
    },
    INX => sub {
        system_register('X', system_register('X') + 1);
        register_check('X');
    },
    JMP => sub { 
        set_operand();
        program_set_address($access_mode, $operand);
    },
    JSR => sub {
        set_operand();
        system_stack(system_register('C'));
        program_set_address($access_mode, $operand);
    },
    LDA => sub { load_register('A', 1); },
    LDD => sub { load_register('D'); },
    LDF => sub { load_register('F'); },
    LDI => sub { load_register('I', 1); },
    LDS => sub { load_register('S', 1); },
    LDX => sub { load_register('X', 1); },
    LSR => sub {
        set_operand();
        set_memory(get_memory() >> 1);
        memory_check();
    },
    MUL => sub {
        set_operand();
        system_register('A', system_register('A') * get_memory());
        register_check('A');
    },
    OPB => sub {
        set_operand();
        system_register('D', get_memory());
        unshift(@ARGV, sprintf(
            "%016b",
            system_register('D')
        ));
    },
    OPD => sub {
        set_operand();
        system_register('D', get_memory());
        unshift(@ARGV, sprintf(
            "%d",
            system_register('D')
        ));
    },
    OPH => sub {
        set_operand();
        system_register('D', get_memory());
        unshift(@ARGV, sprintf(
            "%08X",
            system_register('D')
        ));
    },
    OPO => sub {
        set_operand();
        system_register('D', get_memory());
        unshift(@ARGV, sprintf(
            "%#o",
            system_register('D')
        ));
    },
    OUT => sub {
        set_operand();
        system_register('D', get_memory());
        unshift(@ARGV, sprintf(
            "Program output: %1\$016b: %1\$u, (%1\$d)",
            system_register('D')
        ));
    },
    ORA => sub {
        set_operand();
        system_register('A', system_register('A') | get_memory());
        register_check('A');
    },
    PHA => sub { system_stack(system_register('A')); },
    PHP => sub { system_stack(system_register('F')); },
    PHV => sub {
        set_operand();
        system_register('D', get_memory());
        push(@ARGV, system_register('D'));
    },
    PLA => sub { 
        system_register('A', system_stack());
        register_check('A');
    },
    PLP => sub { system_register('F', system_stack()); },
    PLV => sub {
        set_operand();
        system_register('D', pop(@ARGV));
        register_check('D');
        if ( $access_mode == $addressing{Accumulator} ) {
            system_register('A', system_register('D'));
        } else {
            system_memory($access_mode, $operand, system_register('D'));
        }
    },
    PRT => sub {
        set_operand();
        system_register('D', get_memory());
        printf(
            "Program output: %1\$016b: %1\$u, (%1\$d)\n",
            system_register('D')
        );
    },
    REA => sub {
        set_operand();
        print "AsmComp input: ";
        if ( @ARGV ) {
            system_register('D', unshift(@ARGV));
            printf("%s\n", system_register('D'));
        } else {
            $| =1;
            $_ = <STDIN>;
            chomp;
            system_register('D', $_);
        }
        register_check('D');
        if ( $access_mode == $addressing{Accumulator} ) {
            system_register('A', system_register('D'));
        } else {
            system_memory($access_mode, $operand, system_register('D'));
        }
    },
    ROL => sub {
        set_operand();
        my $value = get_memory();
        system_flag('C', undef, $value & (~0^~0>>1));
        set_memory(($value << 1) + system_flag('C'));
        memory_check();
    },
    ROR => sub {
        set_operand();
        my $value = get_memory();
        system_flag('C', undef, $value & 1);
        if ( system_flag('C') ) {
            set_memory(($value >> 1) | (~0^~0>>1));
        } else {
            set_memory($value >> 1);
        }
        memory_check();
    },
    RTI => sub {
        system_register('F', system_stack());
        system_register('C', system_stack());
    },
    RTS => sub { system_register('C', system_stack()); },
    SBC => sub {
        set_operand();
        system_register('A', system_register('A') - get_memory());
        map {
            system_flag($_, undef, system_register('A'));
        } qw(N V Z C);
    },
    SEC => sub { system_flag('C', 1); },
    SED => sub { system_flag('D', 1); },
    SEI => sub { system_flag('I', 1); },
    SEX => sub { system_flag('X', 1); },
    STA => sub { store_register('A'); },
    STD => sub { store_register('D'); },
    STI => sub { store_register('I'); },
    STP => sub { 
        system_flag('B', 1);
        core_dump()
            if ( system_flag('D') );
    },
    STX => sub { store_register('X'); },
    TAD => sub { copy_register('A', 'D'); },
    TAI => sub { copy_register('A', 'I'); },
    TAX => sub { copy_register('A', 'X', 1); },
    TDA => sub { copy_register('D', 'A', 1); },
    TDX => sub { copy_register('D', 'X', 1); },
    TIA => sub { copy_register('I', 'A', 1); },
    TIX => sub { copy_register('I', 'X', 1); },
    TSX => sub { copy_register('S', 'X', 1); },
    TXA => sub { copy_register('X', 'A', 1); },
    TXD => sub { copy_register('X', 'D'); },
    TXI => sub { copy_register('X', 'I'); },
    TXS => sub { copy_register('X', 'S'); },
);

$asmcode{DIV} = sub {
    set_operand();
    my $value = get_memory();
    if ( 0 == $value ) {
        system_flag('Z', 1);
        system_flag('V', 1);
        system_flag('B', 1);
        $asmcode{BRK}();
    }
    system_register('X', system_register('A') % $value);
    system_register('A', int(system_register('A') / $value));
    register_check('A');
};

sub memory_load {
    load_memory(@_, 0, 0, 0 );
};

sub run_code {
    while ( ! system_flag('I') && ! system_flag('B') && system_register('C') < program_length() ) {
        $asmcode{program_next_code()}();
    }
}

sub one_shot {
    $asmcode{$_[0]}();
}

sub soft_start {
    map {
        system_register($_, 0);
    } qw(A C I S X D);
    map {
        system_flag($_, 0);
    } qw(N V B I Z C);
    system_memory( (0) x4 );
}

sub code_execute {
    system_flag('X', 0);
    run_code();
    return system_register('D') if ( system_flag('X') );
    return 1 if ( system_flag('B') );
    return 0 if ( system_flag('I') );
    return undef;
}

sub program_run {
    map {
        system_register($_, 0);
    } qw(A C I S X D);
    code_execute();
}

sub program_resume {
    $asmcode{'RTI'}();
    code_execute();
}

sub program_step {
    return program_run() 
        if ( 0 == system_register('S') );
    $asmcode{'RTI'}();
    code_execute();
}

1;
__END__

=head1 NAME

IntCode::AsmComp::AsmCodes

=head1 SYNOPSIS

  use IntCode::AsmComp::AsmCodes;

=head1 DESCRIPTION

Implementation of the assembly-level workings of the IntCode computer
needed by the elves in the 2019 Advent of Code challenges.

=head2 EXPORT

	program_load
	memory_load
    direct_memory_access
    program_resume
	program_run
    program_step
    one_shot
    soft_start

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
