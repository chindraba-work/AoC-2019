package IntCode::ElfComp;

# SPDX-License-Identifier: MIT

use 5.026001;
use strict;
use warnings;
use Elves::GetData qw ( read_comma_list );
use IntCode::ElfComp::ElfCodes;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
    elf_launch
    elf_messages
    elf_prompts
    enable_dump
    load_code_file
    load_code_stream
    terminal_memory_access
    warm_boot
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.19.07';

my $stopped;

*load_code_stream       = *IntCode::ElfComp::ElfCodes::load_code;
*terminal_memory_access = *IntCode::ElfComp::ElfCodes::memory_terminal;
*warm_boot              = *IntCode::ElfComp::ElfCodes::elf_restart;


sub elf_prompts {
    if ( @_ ) {
        push(@prompts,reverse(@_));
    } else {
        $#prompts = -1;
    }
}

sub elf_messages {
    if ( @_ ) {
        push(@messages,reverse(@_));
    } else {
        $#messages = -1;
    }
}

sub enable_dump {
    if ( 0 < @_  && 1 == $_[0] ) {
        raw_asm('SED');
    } else {
        raw_asm('CLD');
    }
}

sub load_code_file {
    load_code(read_comma_list(@_));
}

sub elf_launch {
    $stopped = undef;
    $stopped = elf_step()
        until $stopped;
}

1;
__END__

=head1 NAME

IntCode::ElfComp

=head1 SYNOPSIS

  use IntCode::ElfComp;

=head1 DESCRIPTION

The Interger Computer the elves need to help Santa in the Advent of
Code challenges for 2019.

Exported routines are:
    elf_launch()
        Begin running the ElfScript program from the beginning.
        Return: nothing
    elf_messages(['list','of','messages'])
        Loads the messages used for prefacing outputs. Listed in the
            order to be used. To create an empty list, the default, 
            pass in an empty list (). Each output statement encountered
            will use the next one in the list. There are no provisions
            for selecting, or skipping, a message, nor of connecting a
            specific message to a specific output command. Any ouput
            commands encountered once the list is exhausted, including
            the first with an empty list, will have no preface, and
            will be output directly from the ElfScript program.
        Return: nothing
    elf_prompts(['list','of','prompts'])
        Loads the prompts used for input commands. The usage and effect
            is the same as for elf_messages, except that if no prompt
            is available, a default prompt of "ElfComp input:" will be
            used.
        Return: nothing
    enable_dump([0|1])
        Controls the option to print a core dump when a RTI or STP is
            executed. An argument of (1) turns on the option, any other
            argument, including empty or non-zero other than 1, will 
            disable the option. Useful for debugging purposes.
        Return: nothing
    load_code_file(file_name)
        Reads the named file, as a single line of comma-separated list
            of ElfScript integer commands and places it in the data
            memory of the AsmComp. Multi-line files are not supported
            and have unpredictable results.
        Return: nothing
    load_code_stream(list,of,commands)
        Stores the list of commands in the AsmComp data memory. There
            are no safeguards of checks applied to the list. When using
            an ElfScript program which will be run multiple times for a
            single run of the controlling program, it is preferable to 
            load the file once, using local storage, for multiple runs
            of the ElfScript rather than repeatedly reading the from 
            disk to load the ElfScript.
        Return: nothing
    terminal_memory_access(address[,value])
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
    warm_boot()
        Clear system registers and flags, remove any ghosts from the 
            AsmComp code memory, wipe the ElfScript from data memory
            and reset the ElfScript code pointer. Places the system in
            the same state as if the Perl program had just been run,
            except that the setting for enable_dump is preserved.
        Return: nothing

=head2 EXPORT

    elf_launch
    elf_messages
    elf_prompts
    enable_dump
    load_code_file
    load_code_stream
    terminal_memory_access
    warm_boot

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
