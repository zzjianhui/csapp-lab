
ArchLab Release Notes
10/19/2016

    Fixed a bug in pipe/correctness.pl that allowed programs that are too long to get full credit. Thanks to Jenna MacCarly, Carnegie Mellon 

4/1/2015
This is a major update of the Arch Lab that reflects the changes in Chapter 4 of CS:APP3e.

    Updated all tools and programs from Y86 (32-bit) to Y86-64 (64-bit). 

7/29/2013

    Updated autograders to compute and summarize all autograded scores on the gradesheets.
    Fixed some typos in the writeup and the slides.
    In the writeup, updated references to problem numbers for iaddl and leave to include the corresponding problem numbers for the international version. 

5/1/2011
This is a major update of the Arch Lab that reflects the changes in Chapter 4 of CS:APP2e.

    Students can now use the conditional move instructions to avoid the performance problems of conditional jumps.
    The benchmark test has a random selection of positive vs. negative numbers. So, conditional moves are really the way to go.
    The correctness check is more robust, looking for things like overshooting the array bounds.
    Added a 1000-byte limit on the size of the object code for the ncopy function.
    Added Perl scripts in src/ptest that provide comprehensive regression testing of the different Y86 simulators:
        Tests each individual instruction type.
        Tests all of the jump types under different conditions.
        Tests different pipeline control combinations.
        Tests many different hazard possibilities. 
    Incorporated the regresssion tests in src/ptest into the autograding of the student solutions for parts B and C. 

11/04/2004

    Fixed problem that caused some newer Linux distributions to get tk.h from /usr/local/include instead of /usr/include. Thanks to Prof. Dr. Gerd Doeben-Henisch, Fachhochschule Frankfurt. 

12/22/2003

    Fixed minor bug that caused some compilers to complain. Changed type of return value from getopt() from char to int. Thanks to Morgan Harvey, Portland State University. 

8/5/2002

    Initial release. 

