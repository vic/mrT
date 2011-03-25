Using PipeSelector with command redirection and custom shell actions.


Basic _PipeSelector_ usage.
---------------------------

Following the _UNIX_ tradition, _MrT_ is able to be part of a
command pipe, that is taking input from one program and sending 
output as the input of another program.

To use the _PipeSelector_, you need to give a single <code>-</code>
argument to the _mrt_ program.


Consuming input from another program.
-------------------------------------

The following pair of examples behave exactly equal, they allow
you to select _foo_ or _bar_.


      # read selectable items from standard input.
      $ echo -e "foo\nbar" | mrt -

      # use arguments after the -- as selectable items.
      $ mrt - -- foo bar


Specifying Actions as command line arguments.
---------------------------------------------

Most of the time you'll want to perform some action on a selected
value. When you select an item in _MrT_ and press the <code>TAB</code>
key on it, a list of available actions will be shown.

As _PipeSelector_ is quite generic, it provides an easy and quick
way to specify possible actions to perform.

Suppose you find yourself searching for a javascript file across
all your filesystem and performing a defined set of actions upon
them. Say, you want to run, compress, and check for lint errors:

      $ locate *.js | mrt - --js --gzip --jslint

As you can see, the easiest way to specify an action is to simply
give a command-name as a _POSIX_ *long option* to the _mrt_ program.



Using more descriptive actions.
-------------------------------

The following example illustrates how to set the description for 
a given action. Simply use a semicolon <code>:</code> after the
action name. *Note* each action is still a single argument.

      $ locate *.js | mrt --js:'Run on the JVM' --node:'Run on Node.js'



Custom shell commands.
----------------------

Sometimes specifying a single command name is not enough, and
you'd like to specify a custom shell command to execute as action.

Suppose you'd like to have a command to select one entry from your
_/etc/fstab_ file and being able to mount and umount it. This example
shows that using a non-option argument after an action name specifies
the shell command to execute.

      $ cat /etc/fstab  | mrt - --mount "sudo mount -t %3 -o %4 %1 %2" --umount "sudo umount %2" 

*Node* you can use _placeholders_ inside the action command. 
<code>%0</code> is a reference to the selected line content.
<code>%1</code> is the first non-blank string from the selected line.
<code>%2</code> is the second non-blank string and so forth.

Another example that lets you start/stop a system service. We escape
the new-line only for formating reasons.

      $ ls /etc/init.d/* -d | mrt - \
           --start 'sudo %0 start' \
           --stop 'sudo %0 stop' \
           --restart 'sudo %0 restart' \
           --status 'sudo %0 status'

Select and extract a single file from a tar archive.

      $ tar -tf some.tar | mrt - --extract 'tar -xf some.tar %0'


Using Pipes to redirect _MrT_'s output to another program.
----------------------------------------------------------

The following alias defines a *pity* command to select a process and
kill it. There are possible better ways to implement it, but we just 
want to use this to illustrate how to pipe output into another program.

      $ alias pity="ps -eopid,cmd | mrt - 3>&1 1>&2 2>&3 | awk '{print\$1}' | xargs kill"

*Note*  all that IO redirection is required because _mrt_ has a curses
based interface, which means it needs to write to you and read your
input.


The following *sig* alias acts much like *pity* but uses named actions
to provide a menu of which signal you want to send to the selected process.

      alias sig="ps -eopid,cmd | mrt -
                 --SIGHUP:'Hangup [see termio(7)]' 'kill -s SIGHUP %1' \
                 --SIGINT:'Interrupt [see termio(7)]' 'kill -s SIGINT %1' \
                 --SIGQUIT:'Quit [see termio(7)]' 'kill -s SIGQUIT %1' \
                 --SIGILL:'Illegal Instruction' 'kill -s SIGILL %1' \
                 --SIGTRAP:'Trace/Breakpoint Trap' 'kill -s SIGTRAP %1' \
                 --SIGABRT:'Abort' 'kill -s SIGABRT %1' \
                 --SIGEMT:'Emulation Trap' 'kill -s SIGEMT %1' \
                 --SIGFPE:'Arithmetic Exception' 'kill -s SIGFPE %1' \
                 --SIGKILL:'Killed' 'kill -s SIGKILL %1' \
                 --SIGBUS:'Bus Error' 'kill -s SIGBUS %1' \
                 --SIGSEGV:'Segmentation Fault' 'kill -s SIGSEGV %1' \
                 --SIGSYS:'Bad System Call' 'kill -s SIGSYS %1' \
                 --SIGPIPE:'Broken Pipe' 'kill -s SIGPIPE %1' \
                 --SIGALRM:'Alarm Clock' 'kill -s SIGALRM %1' \
                 --SIGTERM:'Terminated' 'kill -s SIGTERM %1' \
                 --SIGUSR1:'User Signal 1' 'kill -s SIGUSR1 %1' \
                 --SIGUSR2:'User Signal 2' 'kill -s SIGUSR2 %1' \
                 --SIGCHLD:'Child Status' 'kill -s SIGCHLD %1' \
                 --SIGPWR:'Power Fail/Restart' 'kill -s SIGPWR %1' \
                 --SIGWINCH:'Window Size Change' 'kill -s SIGWINCH %1' \
                 --SIGURG:'Urgent Socket Condition' 'kill -s SIGURG %1' \
                 --SIGPOLL:'Pollable event' 'kill -s SIGPOLL %1' \
                 --SIGSTOP:'Stopped (signal)' 'kill -s SIGSTOP %1' \
                 --SIGTSTP:'Stopped (user) [see termio(7)]' 'kill -s SIGTSTP %1' \
                 --SIGCONT:'Continued' 'kill -s SIGCONT %1' \
                 --SIGTTIN:'Stopped (tty input) [see termio(7)]' 'kill -s SIGTTIN %1' \
                 --SIGTTOU:'Stopped (tty output) [see termio(7)]' 'kill -s SIGTTOU %1' \
                 --SIGVTALRM:'Virtual Timer Expired' 'kill -s SIGVTALRM %1' \
                 --SIGPROF:'Profiling Timer Expired' 'kill -s SIGPROF %1' \
                 --SIGXCPU:'CPU time limit exceeded [see getrlimit(2)]' 'kill -s SIGXCPU %1' \
                 --SIGXFSZ:'File size limit exceeded [see getrlimit(2)]' 'kill -s SIGXFSZ %1' \
                 --SIGWAITING:'All LWPs blocked' 'kill -s SIGWAITING %1' \
                 --SIGLWP:'Virtual Interprocessor Interrupt for Threads Library' 'kill -s SIGLWP %1' \
                 --SIGAIO:'Asynchronous I/O' 'kill -s SIGAIO %1'"

