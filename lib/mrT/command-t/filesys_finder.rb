require 'command-t/ext' # CommandT::Matcher
require 'command-t/finder'
require 'mrT/command-t/filesys_scanner'

module CommandT
  # File system finder. It can search for:
  #  * Files
  #  * Directories
  #  * Both
  # It supports different filtering methods:
  #  * Glob patterns
  #  * Git aware (gitignore)
  class FilesysFinder < Finder
    def initialize(path = Dir.pwd, options = {})
      @scanner = FilesysScanner.new path, options
      options[:never_show_dot_files] =
          !(options[:always_show_dot_files] = !!options.delete(:show_dot_files))
      @matcher = Matcher.new @scanner, options
    end
  end
end
