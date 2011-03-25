require 'command-t/scanner'

module CommandT
  class Scanner

    private

    git_root = MrT.git_root

    @@ignore_patterns =
      ([] if git_root && !MrT.config[:patterns_in_git_repo]) ||
      MrT.config[:ignore_patterns]

    @@ignored_files =
      (git_root && MrT.config[:use_git_ignore] &&
      # This should be a sorted list, so we can use a binary search.
      Hash[ `git ls-files --others --no-empty-directory --full-name`.split("\n").zip ]) ||
      {}

    def path_excluded? path
      # Strip common prefix (@path) from path
      path = path[(@prefix_len + 1)..-1]
      @@ignored_files.key?(path) || @@ignore_patterns.any? { |p| File.fnmatch? p, path }
    end

  end
end
