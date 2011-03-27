require 'command-t/scanner'

module CommandT
  # File system scanner. It can search recursively for:
  #  * Files
  #  * Directories
  #  * Both
  # It supports different filtering methods:
  #  * Glob patterns
  #  * Git aware (gitignore)
  #
  #  Based on CommandT::FileFinder
  class FilesysScanner < Scanner
    class FileLimitExceeded < ::RuntimeError; end

    def initialize path = Dir.pwd, options = {}
      @path                 = path
      @max_depth            = options[:max_depth] || 15
      @max_files            = options[:max_files] || 10_000
      @scan_dot_directories = options[:scan_dot_directories] || false
    end

    def paths
      return @paths unless @paths.nil?
      begin
        @paths = []
        @depth = 0
        @files = 0
        @prefix_len = @path.chomp('/').length
        add_paths_for_directory @path, @paths
      rescue FileLimitExceeded
      end
      @paths
    end

    def flush
      @paths = nil
    end

    def path= str
      if @path != str
        @path = str
        flush
      end
    end

    private

    git_root = MrT.git_root

    @@ignore_patterns =
      ([] if git_root && !MrT.config[:patterns_in_git_repo]) ||
      MrT.config[:ignore_patterns]

    @@ignored_files =
      (git_root && MrT.config[:use_git_ignore] &&
      Hash[ `git ls-files --others --no-empty-directory --full-name`.split("\n").zip ]) ||
      {}

    def path_excluded? path
      # Strip common prefix (@path) from path
      path = path[(@prefix_len + 1)..-1]
      @@ignored_files.key?(path) || @@ignore_patterns.any? { |p| File.fnmatch? p, path }
    end

    def add_paths_for_directory dir, accumulator
      Dir.foreach(dir) do |entry|
        next if ['.', '..'].include? entry
        path = File.join(dir, entry)
        unless path_excluded? path
          if File.file? path
            @files += 1
            raise FileLimitExceeded if @files > @max_files
            accumulator << path[@prefix_len + 1..-1]
          elsif File.directory? path
            next if @depth >= @max_depth
            next if (entry.match(/\A\./) && !@scan_dot_directories)
            @depth += 1
            add_paths_for_directory path, accumulator
            @depth -= 1
          end
        end
      end
    rescue Errno::EACCES
      # skip over directories for which we don't have access
    end
  end # class FilesysScanner
end
