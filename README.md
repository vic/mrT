Mr T
====

What is it.
-----------

MrT is a curses based file finder. If you're familiar with Textmate's cmd-t,
Vim's [Command-T](http://wincent.com/products/command-t) plugin, or Emacs's
[Anything](http://www.emacswiki.org/emacs/Anything), you'll feel right at home. 

MrT allows you to have fast, file completion from your shell prompt. You can 
use it as-is by invoking the _mrT_ command, or use it as your default file
completion strategy for some unix commands.

Requirements
------------

MrT requires ruby version 1.8.7 or greater, it has been tested with 1.9.2. 
It requires your ruby to have been compiled with the standard _curses_ and 
_readline_ libraries. If you are building your own ruby or are using _rvm_ 
make sure you have needed development libraries before compiling ruby.

We use the [Command-T gem](http://vic.github.com/Command-T/tree/gem), we 
expect our changes can be integrated into Command-T's main repo.


Installation
------------

rake install



Usage
-----

After installation, you might be able to use the _mrT_ binary, right now it 
takes an optional directory as only argument.

     mrT

MrT not only allows you to find files, if you hit the <code>TAB</code> key upon
a selected file, MrT will present a set of actions to execute on it.

Even though MrT was created for fast file finding from the shell prompt, it
is not restricted to work only on files. Actually, because of MrT's addon
design you can easily configure it to complete on anything you want.

As with vim, you can use the _backslash_ key (we call it _Leader_) to change
from one selector to another using _Leader_ + _someKey_. 
Use _Leader_ + _space_ to show available selectors.


Configuration
-------------

A YAML file <code>~/.mrTrc</code> with a Hash content can be used for
configuration.

Default values are:

<pre>
# if true and no directory is specified, mrT tries to guess git project root.
find_git_root: true

# max depth of directories to find files in.
max_depth: 15

# max number of matches to display.
max_files: 10_000

# should hidden directories be scanned?
scan_dot_directories: false

# should hidden files be shown?
show_dot_files: false
</pre>


Future
------

Use Command-T caching features, expose Command-T options as command line flags.


Contribute
----------

Feel free to adapt mrT to your needs, report any issue or send pull requests 
to the github repository:

    http://github.com/vic/mrT

Authors
-------

- [Victor Hugo Borja](http://github.com/vic) <vic.borja@gmail.com>

- [Eduardo Lopez](http://github.com/tapichu)
