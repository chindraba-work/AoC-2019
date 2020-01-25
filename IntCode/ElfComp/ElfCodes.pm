package IntCode::ElfComp::ElfCodes;

# SPDX-License-Identifier: MIT

use 5.026001;
use strict;
use warnings;
use IntCode::AsmComp::Api;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw (
    @messages
    @output_buffer
    $output_filter
    @prompts
    elf_restart
    elf_step
    load_code
    memory_terminal
    raw_asm
    set_pipes
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.19.07';

*load_code       = *IntCode::AsmComp::Api::asm_load_data;
*memory_terminal = *IntCode::AsmComp::Api::asm_memory;
*raw_asm         = *IntCode::AsmComp::Api::asm_command;

my ($elf_index, $op1, $op2, @parameter_mode) = (0) x 6;
our @messages;
our @output_buffer;
our $output_filter;
our @prompts;
my @mode_list = qw(
    Absolute
    Immediate
);
my $pending_output = 0;

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
    3 => sub {
        unless ( @ARGV ) {
            if (defined $asm_handles{input} ) {
                my $fh = $asm_handles{input};
                $_ = <$fh>;
            } else {
                if ( @prompts ) {
                    print STDOUT (pop(@prompts),": ");
                } else {
                    print STDOUT "ElfComp input: ";
                }
                $| =1;
                $_ = <STDIN>;
            }
            chomp;
            unshift(@ARGV, $_);
        }
        return (
            INP => $mode_list[$parameter_mode[0]], elf_next(),
        )},
    4 => sub { 
        $pending_output = 1;
        return (
            OTD => $mode_list[$parameter_mode[0]], elf_next(),
        )},
    5 => sub { return (
            LDA => $mode_list[$parameter_mode[0]], elf_next(),
            BEQ => Relative => 4,
            LDD => $mode_list[$parameter_mode[1]], elf_next(),
            SEX =>
        )},
    6 => sub { return (
            LDA => $mode_list[$parameter_mode[0]], elf_next(),
            BNE => Relative => 4,
            LDD => $mode_list[$parameter_mode[1]], elf_next(),
            SEX =>
        )},
    7 => sub { return (
            LDA => $mode_list[$parameter_mode[0]], elf_next(),
            CMP => $mode_list[$parameter_mode[1]], elf_next(),
            BMI => Relative => 6,
            LDD => Immediate => 0,
            JMP => Relative => 3,
            LDD => Immediate => 1,
            STD => $mode_list[$parameter_mode[2]], elf_next(),
        )},
    8 => sub { return (
            LDA => $mode_list[$parameter_mode[0]], elf_next(),
            CMP => $mode_list[$parameter_mode[1]], elf_next(),
            BEQ => Relative => 6,
            LDD => Immediate => 0,
            JMP => Relative => 3,
            LDD => Immediate => 1,
            STD => $mode_list[$parameter_mode[2]], elf_next(),
        )},
);

sub set_pipes {
    ($asm_handles{input}, $asm_handles{output}) = @_;
}

sub elf_restart {
    asm_warm_boot();
    $elf_index = 0;
}

sub elf_next {
    return memory_terminal($elf_index++);
}

sub elf_step {
    my $step_value;
    ($op2, $op1, @parameter_mode) = (reverse(split('', elf_next())),('0') x 5)[0..4];
    my @asm_snippet = $elf_asm{10 * $op1 + $op2}();
    asm_load_app(@asm_snippet);
    $step_value = asm_app_step();
    if ( $pending_output ) {
        if ( defined $asm_handles{output} ) {
            push(@output_buffer, pop(@ARGV));
        } else {
            my $output_message;
            my $output_value = pop(@ARGV);
            if ( @messages ) {
                $output_message = pop(@messages) . " " . $output_value;
            } else {
                $output_message = $output_value;
            }
            push(@output_buffer, $output_message);
            unless ( $output_filter ) {
                print <STDOUT> "$output_message\n";
            }
        }
        $pending_output = 0;
    }
    if ( 4 & $step_value ) {
        $elf_index = pop @ARGV;
        $step_value = 4 ^ $step_value;
    }
    return $step_value;
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

Exported variables and routines are:
    @messages
        List of the messages used for prefacing outputs. The list is in
            reverse of the order to be used. (Push onto the list).
    @output_buffer
        Collection of values ouput by the code.
    $output_filter
        Signal to filter output, and bypass sending the results of the
            output commands to the live terminal. False allows the use
            of the terminal output <STDOUT>, True prevents it.
    @prompts
        List of the prompts used for input commands. The list is in
            reverse of the order to be used. (Push onto the list).
    elf_restart()
        Clear system registers and flags, remove any ghosts from the 
            AsmComp code memory, wipe the ElfScript from data memory
            and reset the ElfScript code pointer. Places the system in
            the same state as if the Perl program had just been run,
            except that the setting for enable_dump is preserved.
        Return: nothing
    elf_step()
        Retrieve the next ElfScript instruction and covert it into code
            for the AsmComp and execute that.
        Return value:
            0: snippet terminated by reaching end of command list
            1: snippet terminated with BRK command
            2: snippet terminated with STP command
            3: snippet terminated with divide by zero error
    load_code(list,of,commands)
        Stores the list of commands in the AsmComp data memory. There
            are no safeguards of checks applied to the list. When using
            an ElfScript program which will be run multiple times for a
            single run of the controlling program, it is preferable to
            load the file once, using local storage, for multiple runs
            of the ElfScript rather than repeatedly reading the from 
            disk to load the ElfScript.
        Return: nothing
    memory_terminal(address[,value])
        Allows direct access to the ElfScript in data memory of the
            AsmComp. Does not access the AsmComp program memory. The
            first argument is the address, in absolute mode, to access
            and the second argument, if any, is the value to place in
            that location. If the second argument is not given, then
            the memory is unchanged. For writing to the memory, this
            only makes sense to use before the ElfScript program is
            launched. For example, to modify a value, or a few values,
            in the loaded ElfScript before launch. It is also useful
            to read certain memory locations after the ElfScript has
            completed. ElfScript programs are known for placing the
            final value in memory address 0.
        Return: value in the given address, after writing if any
    raw_asm(CMD[, operand[, operand]])
        Allows the execution of exactly one assembly code command. The
            call must include the data for the command, if any. Setting
            and clearing flags, and pre-loading registers for testing
            are the primary purposes for this routine's use.
        Return value: none
    set_pipes(input_handle, output_handle)
        Routine to set the I/O handles for redirection. Uses the API's
            %asm_handles, q.v.
        Return value: none

=head2 EXPORT

    @messages
    @output_buffer
    $output_filter
    @prompts
    elf_restart
    elf_step
    load_code
    memory_terminal
    raw_asm
    set_pipes

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
