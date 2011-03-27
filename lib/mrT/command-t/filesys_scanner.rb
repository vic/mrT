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
      @search_files         = if options[:files].nil? then true else options[:files] end
      @search_directories   = options[:directories] || false
    end

    def paths
      return @paths unless @paths.nil?
      begin
        @paths = []
        @depth = 0
        @items = 0
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

    class << self
      def git_root
        @git_root ||= MrT.git_root
      end

      def ignore_patterns
        @ignore_patterns ||=
          ([] if git_root && !MrT.config[:patterns_in_git_repo]) ||
          MrT.config[:ignore_patterns]
      end

      def ignored_files
        @ignored_files ||=
          (git_root && MrT.config[:use_git_ignore] &&
           Hash[ `git ls-files --others --no-empty-directory --full-name`.split("\n").zip ]) ||
           {}
      end

      def ignored_dirs
        unless @ignored_dirs
          ignored_dirs = []
          if git_root && MrT.config[:use_git_ignore]
            ignored_dirs = `git ls-files --others --directory --full-name`.split("\n")
            ignored_dirs.select! { |item| item.end_with? '/' }
            ignored_dirs.map! { |item| item << '**' }
          end
          @ignored_dirs = ignored_dirs
        end
        @ignored_dirs
      end
    end

    def path_excluded? path
      # Strip common prefix (@path) from path
      path = path[(@prefix_len + 1)..-1]

      if @search_directories
        FilesysScanner.ignored_files.key?(path) ||
          FilesysScanner.ignored_dirs.any? { |d| File.fnmatch? d, path } ||
          FilesysScanner.ignore_patterns.any? { |p| File.fnmatch? p, path }
      else
        FilesysScanner.ignored_files.key?(path) ||
          FilesysScanner.ignore_patterns.any? { |p| File.fnmatch? p, path }
      end
    end

    def add_path path, accumulator
      @items += 1
      raise FileLimitExceeded if @items > @max_files
      accumulator << path[@prefix_len + 1..-1]
    end

    def add_paths_for_directory dir, accumulator
      Dir.foreach(dir) do |entry|
        next if ['.', '..'].include? entry
        path = File.join(dir, entry)
        unless path_excluded? path
          if File.file? path
            if @search_files
              add_path path, accumulator
            end
          elsif File.directory? path
            next if @depth >= @max_depth
            next if (entry.match(/\A\./) && !@scan_dot_directories)
            if @search_directories
              add_path path << '/', accumulator
            end
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
