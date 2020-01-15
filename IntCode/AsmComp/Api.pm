package IntCode::AsmComp::Api;

# SPDX-License-Identifier: MIT

use 5.026001;
use strict;
use warnings;
use IntCode::AsmComp::AsmCodes;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
    access_memory
    command
    load_program
    load_memory
    launch_application
    resume_application
    step_application
    reboot
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.19.07';

*reboot             = *IntCode::AsmComp::AsmCodes::soft_start;
*load_program       = *IntCode::AsmComp::AsmCodes::program_load;
*load_memory        = *IntCode::AsmComp::AsmCodes::memory_load;
*launch_application = *IntCode::AsmComp::AsmCodes::program_run;
*resume_application = *IntCode::AsmComp::AsmCodes::program_resume;
*step_application   = *IntCode::AsmComp::AsmCodes::program_step;
*access_memory      = *IntCode::AsmComp::AsmCodes::direct_memory_access;
*command            = *IntCode::AsmComp::AsmCodes::one_shot;

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

=head2 EXPORT

    access_memory
    command
    load_program
    load_memory
    launch_application
    resume_application
    step_application
    reboot

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
