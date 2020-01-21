package IntCode::AsmComp;

# SPDX-License-Identifier: MIT

use 5.026001;
use strict;
use warnings;
use IntCode::AsmComp::AsmCodes;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
    asm_boot
    program_continue
    program_restart
    system_memory
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.19.07';

*program_continue = *IntCode::AsmComp::AsmCodes::code_resume;
*system_memory = *IntCode::AsmComp::AsmCodes::direct_memory_access;

sub asm_boot {
    my %system_data = @_;
    load_code(@{$system_data{'code'}})
        if ( defined $system_data{'data'} );
    load_memory(@{$system_data{'data'}})
        if ( defined $system_data{'data'} );
    unshift(@ARGV, @{$system_data{'input'}})
        if ( defined $system_data{'input'} );
    return code_launch();
}

sub program_restart {
    soft_start();
    return code_launch();
}


1;
__END__

=head1 NAME

IntCode::AsmComp

=head1 SYNOPSIS

  use IntCode::AsmComp;

=head1 DESCRIPTION

The "terminal" interface to the  Assembly computer, built to handle the
computing needs of the elves in the 2019 Advent of Code challenges.

This acts as the OS-level interface for programs built to run on the
computer directly, rather than as a backend to some other system. The
presumption is that the Perl code calling this interface will do very
little to control the computer and it's I/O acting more like an
assembler than a supervising program. For anything other than simple
input and output, the calling script will need to do some work. The
return code from running the program should be sufficient to that need.

Exported routines are:
    asm_boot(%system_data)
        Load the given data into the data segment of the computer, load
            the supplied codes into the code segment of the computer,
            pre-load ARGV, clear the registers and flags, and begin
            execution of the code.
        As a result of the clearing of registers and flags, the program
            can be relaunched without the need to restart the Perl which
            controls the process.
        The handling of I/O is controlled by the calling Perl combined
            with the actual codes in the "program" itself.
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
    program_continue()
        Perform an RTI instruction (pop status register and code
            pointer) and begin executing instructions at the new code
            pointer position. Presumption is that the program has run a
            BRK command, and the Perl script has done the intended 
            functionality and is returning to continue the program. The
            ability to modify or read registers and flags is not a part
            of the interface, and the code of the program will have to
            make them available using other methods prior to the BRK.
            Options include using the output functions to place the
            interested values in ARGV, or storing the data in some place
            in memory, which can be accessed with memory routine.
        Return value: see init
    program_restart()
        Clear the registers, except Status Register, clear flags, except
            D and X flags, and launch the program. Uses the existing
            memory for code and data.
        Return value: see init
    system_memory (memory_address[, new-data])
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

The format of the system_data aregument is:
    %system_data = (
        data => [12, 45, 69, 18],
        code => [
            LDA => Immediate => 0,
            STA => Absolute => 15,
            LDA => Immediate => 0,
            STA => Absolute => 3,
            CMP => Absolute => 12,
            BPL => Absolute => 57,
            TAI =>
            BRK =>
        ],
        input => [ 1,15,'Message line' ],
    )
Where the data element is loaded directly into the memory and the code
element is loaded directly into the code segment of the computer. The
input element is preprocessed and loaded into ARGV for simulating
terminal input, or for use with the other input codes in AsmCodes.


=head2 EXPORT

    asm_boot
    program_continue
    program_restart
    system_memory

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
