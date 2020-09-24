
Buffer Lab Release Notes
9/10/2014

    Fixed a typo in the writeup. Thanks to Prof. Len Hamey, Macquarie University (Australia) 

10/15/2013

    Using gcc 4.8.1 at -O1, inlining is enabled and the frame pointer is disabled, both of which are bad for the buffer bomb. We split the buffer code to a separate file to disable inlining, and added the -fno-omit-frame-pointer compiler flag to enable the frame pointer.
    Made some tweaks to improve validation in bufbomb.
    Tightened up the parsing in the solve scripts. 

4/23/2012

    Some recent gcc builds automatically enable the -fstack-protector option. We now explicitly disable this by compiling the buffer bomb with -fno-stack-protector.
    In order to avoid infinite loops during autograding, the previous update from February 2012 introduced a timeout feature that was always enabled. However, this was a problem for students who were debugging their bombs in gdb. We now enable timeouts only during autograding.

    Thanks to Prof. James Riely, DePaul University for pointing these out to us.

2/21/2012

    In some newer versions of Linux, the location of shared libraries would conflict with user-definedhardwired stack. Added a fix to avoid the conflict. Thanks to Prof. Godmar Back, Virginia Tech, for teaching us how to do this.
    To protect against infinite loops in student exploit strings during autograding, each buffer bomb now always times out after 5 seconds. Thanks to Prof. Godmar Back, Virginia Tech.
    Increased the amount of randomization during the nitro phase. Thanks to Prof. Godmar Back, Virginia Tech.
    Cleaned up some indenting issues in the source code. 

9/7/2011

    Fixed a bug in buflab-requestd.pl where the request server would sometimes return a non-notifying buffer bomb. Thanks to Prof. Godmar Back, Virginia Tech.
    Added some clearer error messages to driverlib.c for those cases where a notifying bomb can't resolve the server address or can't connect to the server. 

8/22/2011

    Modified the "start" rule in Makefile to touch the log.txt file before starting up the lab daemons, so that an empty scoreboard is created initially. Thanks to Prof. Godmar Back, Virginia Tech. 

1/2/2011
This is a major update of the Buffer Lab:

    This version of the lab has been specially modified to defeat the stack randomization techniques used by newer versions of Linux. On entry, the bufbomb creates a stable stack location across all platforms by using mmap() and an assembly language insert to move the stack pointed at by %esp to an unused part of the heap.
    Introduced a new stand-alone, user-level HTTP-based autograding service (based on the new Bomb Lab autograder) that hands out buffer bombs on demand, tracks successful solutions in real-time on a scoreboard, and serves the scoreboard to browsers. The service also maintains a handin directory that contains the most recent submissions from each student, along with a report showing the output from the autograder.
    Introduced a powerful new tool, called hex2raw, that allows students to encode their exploit strings as simple text files, where each byte in the exploit string is represented as a pair of hex digits. Further, exploit strings can be annotated using C block comments.
    Introduced a new master solver program, called solve.pl that uses gdb to automatically generate an annotated exploit string for any userid and level.
    The writeup contains a lot of additional information to help students solve their bombs. 

4/28/2004

    Closed a loophole that allowed some students to use the "candle" exploit string to receive credit for the "sparkler" and "firecracker" stages. The fix is a simple check to make sure validation only happens after proper function entry. Thanks to Prof. Bill Bynum, William and Mary. 

1/20/2004

    Some recent versions of Linux include a shield to avoid stack exploit problems. With this shield in place, the lab becomes much too difficult. On some systems, the shield can be disabled temporarily (until the machine is rebooted) by writing into the proc file system:
    On older Linux 2.4 systems:
    echo 0 > /proc/sys/kernel/exec-shield-randomize
    On newer Linux 2.6 systems:
    echo 0 > /proc/sys/kernel/randomize_va_space

    You can make this happen automatically at boot time by including one of the above commands in /etc/rc.d/rc.local
    Thanks to Umberto Villano. 

3/31/2003

    The old autograder would fail on programs compiled with newer versions of GCC because these versions use different amounts of stack padding than older versions. The new autograder now detects the amount of padding automatically, and thus works with any version of GCC. Thanks to Prof. Chris Carothers, RPI.

    The autograder now includes the buffer bomb generation number on the status Web page. 

10/16/2002

    Minor modifications to improve the clarity of the writeup.

    Minor modifications to the autograders:
        gengrades.pl now gives 0 points for an invalid submission rather than 1/4 credit.
        genhtml.pl no longer prints the border around icons.
        genhtml.pl now uses smaller more attractive icons. 

6/3/2002

    Initial release. 

