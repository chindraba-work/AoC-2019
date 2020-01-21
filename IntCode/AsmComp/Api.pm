package IntCode::AsmComp::Api;

# SPDX-License-Identifier: MIT

use 5.026001;
use strict;
use warnings;
use IntCode::AsmComp::AsmCodes;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
    asm_app_launch
    asm_app_resume
    asm_app_step
    asm_command
    asm_load_app
    asm_load_data
    asm_memory
    asm_warm_boot
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.19.07';

*asm_app_launch = *IntCode::AsmComp::AsmCodes::code_launch;
*asm_app_resume = *IntCode::AsmComp::AsmCodes::code_resume;
*asm_app_step   = *IntCode::AsmComp::AsmCodes::code_step;
*asm_command    = *IntCode::AsmComp::AsmCodes::one_shot;
*asm_load_app   = *IntCode::AsmComp::AsmCodes::load_code;
*asm_load_data  = *IntCode::AsmComp::AsmCodes::load_memory;
*asm_memory     = *IntCode::AsmComp::AsmCodes::direct_memory_access;
*asm_warm_boot  = *IntCode::AsmComp::AsmCodes::hard_start;

1;
__END__

=head1 NAME

IntCode::AsmComp::Api

=head1 SYNOPSIS

  use IntCode::AsmComp::Api;

=head1 DESCRIPTION

Application programming interface to the Assembly computer, built to
handle the computing needs of the elves in the 2019 Advent of Code
challenges.

Exported routines are:
    asm_app_launch()
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
    asm_app_resume()
        Perform and RTI instruction (pop status register and code
            pointer) and begin executing instructions at the new code
            pointer position.
        Return value: see asm_app_launch
    asm_app_step()
        Based on the value of the Stack Pointer, either do a asm_app_launch
            or asm_app_resume. If the Stack Pointer indicates that there
            is data on the stack, asm_app_resume is the choice. So long
            as the snippets do not place data on the stack, this allows
            for a set of snippets to be executed while retaining the
            status of all the flags, and clearing all the registers.
            There is no provisions to run snippets in series while
            retaining register values as well. To do this requires that
            the snippets take control over the data in the registers,
            using memory space between invocations to hold their data.
        Return value: see asm_app_launch
    asm_command(CMD[, operand[, operand]])
        Allows the execution of exactly one assembly code command. The
            call must include the data for the command, if any. Setting
            and clearing flags, and pre-loading registers for testing
            are the primary purposes for this routine's use.
        Return value: none
    asm_load_app(program_code_list)
        Directly load the program into memory. The raw contents of the
            argument list is copied into the code segment of the
            "computer". No checks or tests of any kind are performed.
        Return value: none
    asm_load_data(memory_data_list)
        Directly load the data into memory. The raw contents of the
            argument list is copied into the data segment of the
            "computer". No checks or tests of any kind are performed.
        Return value: none
    asm_memory(memory_address[, new-data])
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
    asm_warm_boot([program_code_list])
        Clears the registers, except the status register, and flags,
            expect for the Decimal and X flags, wipes the data segment
            and reloads the code segment with the arguments, if any.
        Return value: none

=head2 EXPORT

    asm_app_launch
    asm_app_resume
    asm_app_step
    asm_command
    asm_load_app
    asm_load_data
    asm_memory
    asm_warm_boot

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
