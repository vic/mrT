require 'command-t/scanner'

module CommandT
  class Scanner

    private

    def path_excluded? path
      # Strip common prefix (@path) from path
      path = path[(@prefix_len + 1)..-1]
      MrT.config[:ignore_patterns].any? do |pattern|
        File.fnmatch? pattern, path
      end
    end

    # TODO: use gitignore if :use_git_ignore is true
    # .gitignore, $GIT_DIR/info/exclude and core.excludesfile
    # git ls-files --others --ignored --exclude-standard

  end
end
