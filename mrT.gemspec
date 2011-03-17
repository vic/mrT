Gem::Specification.new do |s|
  s.name = "mrT"
  v = `git describe --abbrev=0`.chomp
  s.version = v

  s.authors = ["Victor Hugo Borja"]
  s.date = "2011-03-17"
  s.email = "vic.borja@gmail.com"

  files =
    ["README.md", "LICENSE", "Gemfile", "Rakefile"] +
    Dir.glob("{lib,bin}/**/*")

  files = files.reject { |f| f =~ /\.(rbc|o|log|plist|dSYM)/ }

  s.files = files
  s.require_path = "lib"

  s.executables = ["mrT"]

  s.has_rdoc = false
  s.homepage = "http://github.com/vic/mrT"

  s.summary = "A curses based file finder using Command-T algorithm."

  s.description = <<EOS
  MrT is a tiny curses application that allows you to easily find a file
  from your shell prompt. It uses the ruby binding from Command-T vim plugin[0].

  You can use MrT standalone or as your default file completion function in bash.

  [0] https://wincent.com/products/command-t
EOS

end
