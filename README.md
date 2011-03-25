Mr T
====

![MrT](http://images2.memegenerator.net/ImageMacro/6477443/I-pity-the-fool-who-doesnt-use-mrT.jpg?imageSize=Medium&generatorName=Mr-T)

What is it.
-----------

MrT is a curses based file finder. If you're familiar with Textmate's cmd-t,
Vim's [Command-T](http://wincent.com/products/command-t) plugin, or Emacs'
[Anything](http://www.emacswiki.org/emacs/Anything), you'll feel right at home. 

MrT allows you to have fast, file completion from your shell prompt. You can 
use it as-is by invoking the _mrt_ command, or use it as your default file
completion strategy for some unix commands.

Requirements
------------

MrT requires ruby version 1.8.7 or greater, it has been tested with 1.9.2. 
It requires your ruby to have been compiled with the standard _curses_ and 
_readline_ libraries. If you are building your own ruby or are using _rvm_ 
make sure you have needed development libraries before compiling ruby.

We use the [Command-T gem](http://github.com/vic/Command-T/tree/gem), we 
expect our changes can be integrated into Command-T's main repo.


Installation
------------

    rake install


You might want to add the *pity* alias to your <code>~/.bashrc</code> to easilly
kill a fool process.

    alias pity="ps -eopid,cmd | mrt - 3>&1 1>&2 2>&3 | awk '{print\$1}' | xargs kill"



Usage
-----

After installation, you might be able to use the _mrt_ binary, right now it 
takes an optional directory as only argument.

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

A YAML file <code>~/.mrtrc</code> with a Hash content can be used for
configuration.

Default values are:

<pre>
# used to determine which files should be excluded from listings.
# this is a list of glob patterns.
ignore_patterns: []

# if true and no directory is specified, mrT tries to guess git project root.
find_git_root: true

# max depth of directories to find files in.
max_depth: 15

# max number of matches to display.
max_files: 10_000

# if you're inside a Git repo, should Mr T use your ignore patterns?
# by default Mr T will only use gitignore
patterns_in_git_repo: false

# should hidden directories be scanned?
scan_dot_directories: false

# should hidden files be shown?
show_dot_files: false

# if you're inside a Git repo, should Mr T ignore the same files as Git?
use_git_ignore: true
</pre>



Customization
-------------

If a <code>.mrtrc.rb</code> file is found at your <code>$HOME</code> directory
it will be automatically loaded. On a git repo you can place it at the root dir.


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
- [Eduardo Lopez](http://github.com/tapichu) <eduardo.biagi@gmail.com>
