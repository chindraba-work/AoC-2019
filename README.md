Advent Of Code 2019

This is the repository for my solutions to the challenges for the 2019 Advent of Code.

The challenges can be reviewed at [https://adventofcode.com/2019](https://adventofcode.com/2019).

Unlike other repos I produce, this will not use [Semantic Versioning](https://semver.org/spec/v2.0.0.html). It seems pointless to do so. Rather changes will be tracked based on the "Day" of the challenge they come from. Hopefully, by day 25, the code for day 1 will still work.

The "version" numbers in the files indicate the "day" for which the code was built, or last modified, and the year of the challenge. As this is the first challenge I've done, I started with version 0.01.01. Having decided that I will probably try the older ones as well, I've switched, retroactively, the versions to be 0.19.01, for Day 1 of 2019 challenge. Since the Advent of Code challenges only go back to 2015 and I will likely not live to work on a challenge in 2100, that should cover any years which I work on. Of course being "Advent" the day will always be from 1 to 25 inclusive.

~~To run these scripts locally, the current directory needs to be in the `@INC` list, which was the default, but has been changed for security concerns. That change can be reversed by using the Bash command `export PERL_USE_UNSAFE_INC=1`, or by adding the line `use lib "."` to the main launching Perl file. Of course, the safe choice is to add the directories from the repo to your `site_perl` directory. That's a good option for my development, not so good for someone wanting to test my code.~~

Day Two involves creating a computer to run "Intcode" programs. This will be a long project for me as I'm not trying to gain points, but want to have fun. This "computer" ought to be a nice challenge if done right.

Built a "computer" to use as the backend for the Elf computer. It is a very loose adaptation of the 6502 chip assembly codes. The functionality of this computer is accessed by adding `use IntCode::AsmComp;` to a Perl file. The IntCode directory is where I will also build the ElfComp computer to use the AsmComp.

As a test of the AsmComp, and for fun, the challenges from Day 1 was recoded to use the AsmComp assembly codes. They both work well, and as assembly code are much shorter than the original Perl file. Of course that ignores the size of the code supporting the AsmComp.

I can see the size of the root directory growing as the Day count climbs, and should consider some kind of menu system in the root and move the challenges to a subdirectory. Maybe....

The need to modify the environment, or the files, has been removed by using the `use inc '.';` work around in the main files myself. Having a menu system, maybe even a yearly directory setup, can simplify this as well. Future project, maybe.

To simplify reading for interested parties, the instructions for the challenges have been reproduced here, in the Challenges directory. I was going to edit them to remove the answers, but realized that there was no point in doing so as the code to create those answers is right here anyway.

Further enhancements for the AsmComp backend made to overhaul the I/O relative to the ElfComp frontend, the managing Perl code, and the user's terminal. Updates to completed solutions (Days 1 - 6) to accomodate the changes where they "break" the developed solutions.

The AsmComp is futher enhanced to allow sensible commandline, and API-controlled, I/O redirection.

# Copyright and License

The MIT license applies to all the code within this repository.

The entire text, and ideas, of the challenges are Copyright [Eric Wastl](https://twitter.com/ericwastl).

Copyright © 2019  Chindraba (Ronald Lamoreaux)
                  <aoc@chindraba.work>
- All Rights Reserved

# The MIT License

```
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
```
