require 'command-t/finder'
require 'mrT/command-t/scanner'

module MrT
  class FileSelect
    def initialize(dir)
      @pattern = []
      @dir = dir || default_dir
      @options = cmd_t_options
      @finder = CommandT::Finder.new @dir, @options
      @ui = UI.new
    end

    def run
      ui.with_curses { interact }
    end

    private

    def selected
      File.expand_path(ui.selected, dir)
    end

    attr_reader :pattern, :dir, :ui

    def default_dir
      if MrT.config[:find_git_root]
        git_dir = `git rev-parse --git-dir 2>/dev/null`.chomp
        if $? == 0
          File.dirname(git_dir)
        end
      end || Dir.pwd
    end

    def cmd_t_options
      keys = [:max_depth, :max_files, :scan_dot_directories, :show_dot_files]
      opts = Hash[keys.zip(MrT.config.values_at(*keys))]
      opts[:never_show_dot_files] =
          !(opts[:always_show_dot_files] = !!opts.delete(:show_dot_files))
      opts
    end

    def interact
      filter
      loop do
        ui.render_line 0, :boldon, ">> ", :boldoff, pattern.join
        ui.refresh
        case c = ui.getch
        when :escape
          return
        when :enter
          return selected
        when :backspace
          pattern.pop
          filter
        when :tab
          action = ActionSelect.new(selected).interact(ui.dup)
          if action
            return action.execute
          else
            ui.redraw
          end
        when (0..255)
          pattern << c.chr
          filter
        end
      end
    end

    def filter
      ui.show @finder.sorted_matches_for(pattern.join)
    end

  end
end
