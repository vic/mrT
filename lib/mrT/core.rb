require 'yaml'
require 'ostruct'

module MrT

  @@defaults = {
    :max_depth => 15,
    :max_files => 10_000,
    :scan_dot_directories => false,
    :show_dot_files => false,
    :find_git_root => true,
    :use_git_ignore => true,
    :patterns_in_git_repo => false,
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
      actions_from_argv!
      pattern_from_argv!
      @cmd
    end

    def actions_from_argv(argv)
      idx, actions, newArgv = -1, Array.new, Array.new
      while arg = argv[idx += 1]
        newArgv << arg
        next unless arg =~ /^--[^-]/
        newArgv.pop
        name, desc = arg[2..-1].split(':', 2)
        cmd = argv[idx + 1]
        cmd = nil if cmd =~ /^--[^-]/
        idx += 1 if cmd
        action = cmd || "exec:#{name} %0"
        actions << Action.with(name, desc, action)
      end
      [actions, newArgv]
    end

    def pattern_from_argv!
      return unless idx = cmd.argv.index('--pattern')
      cmd.pattern = cmd.argv.delete_at(idx+1).to_s.split(//)
      cmd.argv.delete_at(idx)
    end

    def actions_from_argv!
      from_idx = cmd.argv.rindex('--actions')
      return unless from_idx
      subary = cmd.argv[from_idx+1..-1]
      remnant = subary.drop_while { |i| i != '--' }
      cmd.actions, subary = actions_from_argv subary
      cmd.argv = [cmd.argv[0...from_idx],subary,remnant[1..-1]].flatten.compact
    end

    def rest_argv!(argv)
      idx = argv.rindex('--')
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
