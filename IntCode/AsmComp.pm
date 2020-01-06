package IntCode::AsmComp;

# SPDX-License-Identifier: MIT

use 5.026001;
use strict;
use warnings;
use Elves::GetData qw( read_lines );
use IntCode::AsmComp::AsmCodes;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
    boot_system
    init_program
    init_memory
    launch_application
    autostart 
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.01.02';

my @memory_data;
my @program_code;

sub init_memory {
    @memory_data = read_lines($_[0]);
    memory_load(@memory_data);
}

sub init_program {
    @program_code = read_lines($_[0]);
    program_load(@program_code);
}

sub boot_system {
    init_memory($_[0]);
    init_program($_[1]) if ( 2 == @_ );
}

sub launch_application {
    program_run();
}

sub autostart {
    boot_system(@_);
    launch_application;
}


1;
__END__

=head1 NAME

IntCode::AsmComp

=head1 SYNOPSIS

  use IntCode::AsmComp;

=head1 DESCRIPTION

Operational interface to the Assembly computer, built to handle the
computing needs of the elves in the 2019 Advent of Code challenges.

=head2 EXPORT

    boot_system
    init_program
    init_memory
    launch_application
    autostart 

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
