require 'yaml'

module MrT

  @@defaults = {
    :max_depth => 15,
    :max_files => 10_000,
    :scan_dot_directories => false,
    :show_dot_files => false,
    :find_git_root => true
  }

  class << self
    def config
      unless @config
        config = {}
        config_file = File.expand_path('~/.mrTrc')
        if File.exist?(config_file) &&
          Hash === (cfg = YAML.load_file(config_file))
          cfg.each_pair { |k,v| config[k.to_sym] = v }
        end
        @config = @@defaults.merge(config)
      end
      @config
    end

    def git_root
      git_dir = `git rev-parse --git-dir 2>/dev/null`.chomp
      File.dirname(git_dir) if $? == 0
    end

    def dir(default = Dir.pwd)
      @dir ||=
        (ARGV.first if ARGV.first && File.directory?(ARGV.first)) ||
        (git_root if MrT.config[:find_git_root]) ||
        default
    end

    def bin(name)
      ENV['PATH'].split(File::PATH_SEPARATOR).find { |p|
        path = File.expand_path(name, p)
        return path if File.exist?(path)
      }
      nil
    end

    def run(source = 't')
      ui = UI.new
      src = Selector.sources[source].new
      ui.with_curses { src.interact ui }
    end
  end

end



require 'mrT/ui'
require 'mrT/selector'
require 'mrT/file_select'
require 'mrT/git_branch_select'
