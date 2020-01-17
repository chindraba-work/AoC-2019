package IntCode::AsmComp::AsmCodes;

# SPDX-License-Identifier: MIT

use 5.026001;
use strict;
use warnings;
use IntCode::AsmComp::BaseCode;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
	code_launch
	code_resume
	code_step
	direct_memory_access
	load_code
	load_memory
	one_shot
	soft_start
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.19.07';

my $access_mode;
my $operand;

*load_code = *IntCode::AsmComp::BaseCode::program_init;

sub load_memory {
    system_memory(@_, 0, 0, 0 );
};

sub direct_memory_access {
    system_memory($addressing{Absolute}, $_[0], $_[1])
        if ( 2 == @_ );
    return system_memory($addressing{Absolute}, $_[0]);
}

sub set_memory {
    system_memory($access_mode, $operand, $_[0]);
}

sub get_memory {
    return system_memory($access_mode, $operand);
}

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

sub memory_check {
    flag_test(system_memory($access_mode, $operand));
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

sub copy_register {
    system_register($_[1], system_register($_[0]));
    register_check($_[1])
        if ( $_[2] );
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
    INI => sub {
        system_register('I', system_register('I') + 1);
        register_check('I');
    },
    INP => sub {
        set_operand();
        print "AsmComp input: ";
        if ( @ARGV ) {
            system_register('D', shift(@ARGV));
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
    ORA => sub {
        set_operand();
        system_register('A', system_register('A') | get_memory());
        register_check('A');
    },
    OTB => sub {
        set_operand();
        system_register('D', get_memory());
        push(@ARGV, sprintf(
            "%016b",
            system_register('D')
        ));
    },
    OTD => sub {
        set_operand();
        system_register('D', get_memory());
        push(@ARGV, sprintf(
            "%d",
            system_register('D')
        ));
    },
    OTH => sub {
        set_operand();
        system_register('D', get_memory());
        push(@ARGV, sprintf(
            "%08X",
            system_register('D')
        ));
    },
    OTO => sub {
        set_operand();
        system_register('D', get_memory());
        push(@ARGV, sprintf(
            "%#o",
            system_register('D')
        ));
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
            "%s\n",
            system_register('D')
        );
    },
    REA => sub {
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
    RPT => sub {
        set_operand();
        system_register('D', get_memory());
        unshift(@ARGV, sprintf(
            "Program output: %1\$016b: %1\$#o: %1\$08X: %1\$u: (%1\$d)",
            system_register('D')
        ));
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
    SEV => sub { system_flag('V', 1); },
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
    TAS => sub { copy_register('A', 'S'); },
    TAX => sub { copy_register('A', 'X', 1); },
    TDA => sub { copy_register('D', 'A', 1); },
    TDX => sub { copy_register('D', 'X', 1); },
    TIA => sub { copy_register('I', 'A', 1); },
    TIX => sub { copy_register('I', 'X', 1); },
    TSA => sub { copy_register('S', 'A', 1); },
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
    if ( @_ ) {
        program_load(@_);
    } else {
        program_load( (0) x 4 );
    }
}

sub code_execute {
    system_flag('X', 0);
    run_code();
    push(@ARGV, (system_register('D'))
        if ( system_flag('X') );
    return (system_register('F') >> 2) & 7)
        if ( system_flag('B') || system_flag('I') || system_flag('X') );
    return undef;
}

sub code_launch {
    map {
        system_register($_, 0);
    } qw(A C I S X D);
    return code_execute();
}

sub code_resume {
    $asmcode{'RTI'}();
    return code_execute();
}

sub program_step {
    return code_launch() 
        if ( 0 == system_register('S') );
    return code_resume();
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

Exported routines are:
    code_launch()
        Clear the registers and launch the program.
        Return value:
            0: program terminated by reaching end of command list
            1: program terminated with BRK command
            2: program terminated with STP command
            3: program terminated with divide by zero error
            4: program terminated by reaching end of command list, and
                D register contents pushed onto ARGV
            5: program terminated with BRK command, and
                D register contents pushed onto ARGV
            6: program terminated with STP command, and
                D register contents pushed onto ARGV
            7: program terminated with divide by zero error, and
                D register contents pushed onto ARGV
    code_resume()
        Perform and RTI instruction (pop status register and code
            pointer) and begin executing instructions at the new code
            pointer position.
        Return value: see code_launch
    code_step()
        Based on the value of the Stack Pointer, either do a code_launch
            or code_resume. If the Stack Pointer indicates that there
            is data on the stack, code_resume is the choice. So long
            as the snippets do not place data on the stack, this allows
            for a set of snippets to be executed while retaining the
            status of all the flags, and clearing all the registers.
            There is no provisions to run snippets in series while
            retaining register values as well. To do this requires that
            the snippets take control over the data in the registers,
            using memory space between invocations to hold their data.
        Return value: see code_launch
    direct_memory_access(memory_address[, new-data])
        Routine to allow supervising programs to directly read and write
            single addresses within the data segment. The first argument
            is the absolute address to access. There is not method for
            using relative, indexed, or pointer address modes. The 
            second argument, if any, is the raw data to write to the
            indicated memory address. It is possible to use this to put
            strings or floating point numbers into the "computer" memory
            at the address. However, if that is accessed directly by
            "running" program, errors are likely, as the computer is
            designed to deal with integers data only.
        The exception to dealing with non-interger data in memory is the
            PRT command, which performs no processing on the data, and
            simply reads the memory and prints it to <STDOUT> and can
            handle strings, or any other basic data type.
        The one-argument version is to read memory, and the two-argument
            version is to write to memory
        Return value:
            The current contents of the address given.
    load_code(program_code_list)
        Directly load the program into memory. The raw contents of the
            argument list is copied into the code segment of the
            "computer". No checks or tests of any kind are performed.
        Return value: none
    load_memory(memory_data_list)
        Directly load the data into memory. The raw contents of the
            argument list is copied into the data segment of the
            "computer". No checks or tests of any kind are performed.
        Return value: none
    one_shot(CMD[, operand[, operand]])
        Allows the execution of exactly one assembly code command. The
            call must include the data for the command, if any. Setting
            and clearing flags, and pre-loading registers for testing
            are the primary purposes for this routine's use.
        Return value: none
    soft_start([program_code_list])
        Clears the registers, except the status register, and flags,
            expect for the Decimal and X flags, wipes the data segment
            and code segment. Nearly the same as relaunching the script,
            except that the X and Decimal flags, used by external code
            to control certain funtionality of the interface, are kept
            as set by the supervising code, if any.
        Return value: none

The AsmCodes, or assembly codes and what the mean. or do, are
    ABT: Abort
    ADC: Add with carry, add memory to accumulator
    AND: Logical AND accumulator with memory
    ASL: Arithmetic shift left, accumulator one bit to the left
    ASR: Arithmetic shift right, accumulator one bit to the right
    BCC: Branch if Carry flag clear
    BCS: Branch if Carry flag set
    BEQ: Branch if Zero flag set
    BIT: Bit manipulation of the memory
    BMI: Branch if Negative flag set
    BNE: Branch if Zero flag clear
    BPL: Branch if Negative flag clear
    BRK: Break- Push code pointer and status register, set interrupt
    BVC: Branch if Overflow flag clear
    BVS: Branch if Overflow flag set
    CLC: Clear Carry flat
    CLD: Clear Decimal flag
    CLI: Clear Interrupt flag
    CLV: Clear Overflow flag
    CLX: Clear X flag
    CMP: Compare accumulator with memory
    CPX: Compare X register with memory
    DEC: Decrement memory
    DEI: Decrement Index register
    DEX: Decrement X register
    DIV: Divide accumulator by memory
    EOR: Exclusive Or accumulator with memory
    GET: Blocking read of ARGV into memory, see REA
    INC: Increment memory
    INI: Increment Index register
    INP: Prompting read of STDIN, reads ARGV if present instead
    INX: Increment X register
    JMP: Jump to address
    JST: Subroutine jump- push code pointer, jump to address
    LDA: Load accumulator from memory
    LDD: Load D register from memory
    LDF: Load Status register from memory
    LDI: Load Index register from memory
    LDS: Load Stack pointer from memory
    LDX: Load X register from memory
    LSR: Logical shift right
    MUL: Multiply accumulator by memory
    ORA: Bitwise OR accumulator with memory
    OTB: Push memory value as binary number string on ARGV
    OTD: Push memory value as signed decimal number string on ARGV
    OTH: Push memory value as hex number string on ARGV
    OTO: Push memory value as octal number string on ARGV
    PHA: Push accumulator onto stack
    PHP: Push status register onto stack
    PHV: Push memory onto ARGV
    PLA: Pop accumulator from stack
    PLP: Pop status register from stack
    PLV: Pop memory from stack
    PRT: Print memory to STDOUT
    REA: Manditory pop ARGV into memory, halts program on failure, see GET
    ROL: Rotate memory left
    ROR: Rotate memory right
    RPT: Push formatted output string onto ARGV
    RTI: Return from interrupt- pop system register, pop code pointer
    RTS: Return from subroutine- pop code pointer
    SBC: Subtract memory from accumulator
    SEC: Set Carry flag
    SED: Set Decimal flag
    SEI: Set Interrupt flag
    SEV: Set Overflow flag
    SEX: Set X flag
    STA: Store accumulator in memory
    STD: Store D Register in memory
    STI: Store Index register in memory
    STP: Stop- set Break flag, end program
    STX: Store X register in memory
    TAD: Transfer accumulator to D register
    TAI: Transfer accumulator to Index register
    TAS: Transfer accumulator to Stack pointer
    TAX: Transfer accumulator to X register
    TDA: Transfer D register to accumulator
    TDX: Transfer D register to X register
    TIA: Transfer Index Pointer to accumulator
    TIX: Transfer Index Pointer to X register
    TSA: Transfer Stack Pointer to accumulator
    TSX: Transfer Stack Pointer to X register
    TXA: Transfer X register to accumulator
    TXD: Transfer X register to D register
    TXI: Transfer X register to Index register
    TXS: Transfer X register to Stack Pointer

The codes, grouped by function:
    Flag controls:
        Clear Flag:
            CLC, CLD, CLI, CLV, CLX
        Set Flag:
            SEC, SED, SEI, SEV, SEX
        Tests:
            CMP, CPX
    Register controls:
        Load register:
            LDA, LDD, LDF, LDI, LDS, LDX, PLA, PLP
        Store register:
            PHA, PHP, STA, STD, STI, STX
        Transfer register:
            TAD, TAI, TAS, TAX, TDA, TDX, TIA, TIX, TSA, TSX, TXA, TXD, TXI, TXS
    Flow controls:
        BCC, BCS, BEQ, BMI, BNE, BPL, BVC, BVS, JMP, JST, RTI, RTS
    Program controls:
        ABT, BRK, STP
    Bit manipulations:
        ASL, ASR, BIT, LSR, ROL, ROR
    Logical operations:
        AND, EOR, ORA
    Math operations:
        ADC, DEC, DEI, DEX, DIV, INC, INI, INX, MUL, SBC
    I/O operations
        Input:
            GET, INP, PLV, REA
        Output:
            OTB, OTD, OTH, OTO, PHV, PRT, RPT

=head2 EXPORT

	code_launch
	code_resume
	code_step
	direct_memory_access
	load_code
	load_memory
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
