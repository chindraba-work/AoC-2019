Advent Of Code 2019

This is the repository for my solutions to the challenges for the 2019 Advent of Code.

The challenges can be reviewed at [https://adventofcode.com/2019](https://adventofcode.com/2019).

Unlike other repos I produce, this will not use [Semantic Versioning](https://semver.org/spec/v2.0.0.html). It seems pointless to do so. Rather changes will be tracked based on the "Day" of the challenge they come from. Hopefully, by day 25, the code for day 1 will still work.

To run these scripts locally, the current directory needs to be in the `@INC` list, which was the default, but has been changed for security concerns. That change can be reversed by using the Bash command `export PERL_USE_UNSAFE_INC=1`, or by adding the line `use lib "."` to the main launching Perl file. Of course, the safe choice is to add the directories from the repo to your `site_perl` directory. That's a good option for my development, not so good for someone wanting to test my code.

Day Two involves creating a computer to run "Intcode" programs. This will be a long project for me as I'm not trying to gain points, but want to have fun. This "computer" ought to be a nice challenge if done right.

# Copyright and License

The MIT license applies to all the code within this repository.

```
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
```