Mr T
====

What is it.
-----------

Mr T is a curses based file finder. If you're familiar with Textmate's cmd-t or
Vim's Command-T plugin, you'll feel right at home. 

Mr T allows you to have fast, file completion from your shell prompt. You can 
use it as-is by invoking the _mrT_ command, or use it as your default file
completion strategy for some unix commands.


Requirements
------------

Mr T requires a ruby compiled with the standard curses library (you need to have
curses-devel installed at ruby configuration time), it also makes use of the ruby 
extension provided by [Command-T](http://wincent.com/products/command-t)


Installation
------------

rake install



Usage
-----

After installation, you might be able to use the _mrT_ binary, right now it 
takes an optional directory as only argument.

     mrT


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
