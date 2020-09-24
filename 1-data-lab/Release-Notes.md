
Data Lab Release Notes
12/16/2019

    Updated writeup and grade directory to match the default puzzle set. Thanks to Chen Su 

11/1/2018

    Corrected a header comment in the satAdd puzzle. Thanks to Prof. Hugh Lauer, Justin Aquilante, and Nick Krichevsky, WPI. 

10/24/2018

    Fixed a build bug in the BDD checker. 

10/23/2018

    Added some new puzzles, fixed a typo in the comment for the rotateRight puzzle, and fixed a build bug in an earlier version. Thanks to Prof. Hugh Lauer, WPI, for identifying the build bug. Thanks to Prof. Bryan Dixon, Cal State Chico, for identifying the rotateRight typo. 

5/4/2016

    Added the -std=gnu89 flag to the dlc Makefile so that gcc 5 will correctly compile dlc (addresses a constraint on inline functions introduced in gcc 5). Thanks to Prof. Branch Archer, West Texas A&M University. 

2/17/2016

    Added a note to the README that bison and flex must be installed in order to rebuild dlc. Thanks to Prof. Michael Ross, Portland Community College. 

9/16/2014

    Applied patch to the ANSI C grammar for dlc to accomodate stricter type rules in more recent versions of bison.
    Eliminated unneccessary calls to bison and flex in the dlc Makefile. Thanks to Prof. Robert Marmorstein, Longwood University. 

9/2/2014

    Fixed bug in grade/grade-datalab.pl autograding script. 

1/30/2014

    Fixed comment in code for logicalShift to indicate that '!' is an allowed operator. Thanks to Prof. Aran Clauson of Western Washington University 

9/19/2012

    Fixed bug in line 147, btest.c: incorrect initial value for NaN. Thanks to Prof. Cary Gray, Wheaton College 

4/26/2012

    Added a clarifying note to the main README file reminding instructors that, because there are different versions of dynamic libraries, Linux binaries such as dlc are not necessarily portable across different Linux platforms. Thanks to Prof. Hugh Lauer, Worcester Polytechnic Institute
    Cleaned up some compiler warnings in the isLessOrEqual.c and isPositive.c puzzle solutions 

8/22/2011

    Modified the "start" rule in Makefile to touch the log.txt file before starting up the lab daemons, so that an empty scoreboard is created initially. Thanks to Prof. Godmar Back, Virginia Tech. 

5/31/2011

    For fun, we've added an optional user-level HTTP-based "Beat the Prof" contest that replaces the old email-based version. The new contest is very simple to run, is completely self-contained, and does not require root password. The only requirement is that you have a user account on a Linux machine with an IP address.
    Corrected a few minor typos in various README files. 

1/2/2011
This is a major update of the Data Lab:

    Introduced floating-point puzzles.
    Added many new integer puzzles (There are now 73 puzzles total).
    Made significant improvements to btest. It now does millions of tests for each puzzle, checking wide swaths around Tmin, 0, denorm-normalized boundary, and inf. Also added support for floating-point puzzles.
    Added support for floating-point puzzles to dlc.
    Added a new autograder called driver.pl that uses dlc and btest to check for correctness and conformance to the coding guidelines.
    Top-level directory now conforms to the CS:APP convention of putting all source files in the ./src directory.
    In driver.pl, replaced "the cp {f1,f2,..,fn} target" notation, which some shells don't handle, with the more portable "cp f1 f2 ... fn target" form.
    The lab writeup is longer included in the datalab-handout directory, to allow instructors greater flexibility in distributing and updating the writeup while the lab is being offered. 

8/29/2003

    Fixed a minor bug that caused btest to test the tc2sm puzzle with an input of Tmin, which isn't defined in sign-magnitude. 

1/27/2003

    More operator-efficient solution to the isPower2.c puzzle. Thanks to Al Davis, Univ of Utah.
    The selections-all.c file now lists all 41 puzzles. 

9/26/2002

    Now includes a prebuilt Linux/IA32 binary for the dlc compiler.
    Fixes a bug (an uninitialized stack variable) that caused "dlc -Z" to crash on some systems.
    Contains some new scripts for running an interactive "Beat the Prof" contest ,
    where students try to outperform the instructor's (intentionally non-optimal) solution. 

6/3/2002

    Initial release. 

