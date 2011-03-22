require 'command-t/finder'

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
      value = ui.with_curses { interact }
      File.expand_path(value, dir) if value
    end

    private

    attr_reader :pattern, :dir, :ui

    def default_dir
      if MrT.config[:find_git_root]
        git_dir = `git rev-parse --git-dir 2>/dev/null`.chomp
        if $? == 0
          File.dirname(git_dir)
        else
          Dir.pwd
        end
      else
        Dir.pwd
      end
    end

    def cmd_t_options
      MrT.config.merge({}).tap { |m|
        m.delete :find_git_root
        m[:never_show_dot_files] =
          !(m[:always_show_dot_files] = !!m.delete(:show_dot_files))
      }
    end

    def interact
      filter
      loop do
        ui.render_line 0, ">> "+pattern.join
        ui.refresh
        case c = ui.getch
        when :escape
          return
        when :enter
          return ui.selected
        when :backspace
          pattern.pop
          filter
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
