require 'command-t/scanner'

module CommandT
  class Scanner

    private

    class << self
      def patterns
        @patterns ||= if MrT.git_root && MrT.config[:use_git_ignore]
                        `git ls-files --others --no-empty-directory --full-name`.split("\n")
                      else
                        MrT.config[:ignore_patterns]
                      end
      end

      def flush_patterns
        @patterns = nil
      end
    end

    # TODO: speed up this implementation, it's slow on big repos with many ignored files
    def path_excluded? path
      # Strip common prefix (@path) from path
      path = path[(@prefix_len + 1)..-1]
      Scanner.patterns.any? do |pattern|
        File.fnmatch? pattern, path
      end
    end

  end
end
