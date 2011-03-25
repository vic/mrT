require 'yaml'
require 'ostruct'

module MrT

  @@defaults = {
    :max_depth => 15,
    :max_files => 10_000,
    :scan_dot_directories => false,
    :show_dot_files => false,
    :find_git_root => true,
    :ignore_patterns => [],
    :selector => 't'
  }

  class << self
    def config
      unless @config
        config = {}
        config_file = File.expand_path('~/.mrtrc')
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

    def selector!
      sel, argv = nil, cmd.argv
      flag = argv.find { |a| a =~ /^-($|[^-])/ &&
                         Selector.sources[a[1..-1]].tap { |s| sel = s } }
      argv.delete(flag) if flag
      cmd.selector = sel || Selector.sources[config[:selector]]
    end

    attr_reader :cmd

    def cmd!(args = nil)
      @cmd = OpenStruct.new
      rest_argv! args
      selector!
      dir!
      @cmd
    end

    def rest_argv!(argv)
      idx = argv.index('--')
      cmd.argv, cmd.rest = idx &&
        [argv[0...idx], argv[idx+1..-1]] || [argv,[]]
    end

    def dir
      cmd.dir
    end

    def dir!(default = Dir.pwd)
      directory = cmd.argv.find { |a| File.directory? File.expand_path(a) }
      cmd.dir ||=
        (File.expand_path(directory) if directory) ||
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

    def require_if_exists(file, path = nil)
      f = File.expand_path(file, path)
      require f if File.file?(f)
    end

    def run
      cmd! ARGV
      require_if_exists '~/.mrtrc.rb'
      require_if_exists '.mrtrc.rb', dir
      selector = cmd.selector.new
      selector.prepare
      exit 1 unless selector.prepared?
      ui = UI.new
      ui.with_curses { selector.interact ui }
    end
  end

end
