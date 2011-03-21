require 'curses'
require 'yaml'
require 'command-t/finder'

class MrT

  @@defaults = {
    :max_depth => 15,
    :max_files => 10_000,
    :scan_dot_directories => false,
    :show_dot_files => false,
    :find_git_root => true
  }

  def self.config
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

  def initialize(dir)
    @str = []
    @dir = dir || default_dir
    @options = cmd_t_options
    @finder = CommandT::Finder.new @dir, @options
  end

  def run
    value = with_curses { interact }
    File.expand_path(value, dir) if value
  end

  private

  attr_reader :str, :shown_from, :dir

  def default_dir
    if config[:find_git_root]
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

  def config
    self.class.config
  end

  def cmd_t_options
    config.merge({}).tap { |m|
      m.delete :find_git_root
      m[:never_show_dot_files] =
        !(m[:always_show_dot_files] = !!m.delete(:show_dot_files))
    }
  end

  def with_curses
    Curses.init_screen
    Curses.nonl
    Curses.cbreak
    Curses.noecho

    @screen = Curses.stdscr
    @screen.scrollok true
    @screen.keypad true

    begin
      yield
    rescue Interrupt
      Curses.close_screen
    ensure
      Curses.close_screen
    end
  end

  def interact
    catch :done do
      filter
      loop do
        Curses.setpos(0,0)
        @screen.clrtoeol
        Curses.addstr('>> ')
        Curses.addstr(str.join)
        @screen.refresh
        c = Curses.getch
        c = c.ord if c.respond_to?(:ord)
        case c
        when 27 # ESCAPE
          throw :done
        when Curses::KEY_ENTER, 13
          throw :done, @matches[@selected]
        when Curses::KEY_RIGHT, 9 # TAB
          item_incr(10)
        when Curses::KEY_LEFT, 353 # SHIT-TAB
          item_incr(-10)
        when Curses::KEY_UP, Curses::KEY_CTRL_P
          item_incr(-1)
        when Curses::KEY_DOWN, Curses::KEY_CTRL_N
          item_incr(1)
        when Curses::KEY_NPAGE
          item_incr(page_size)
        when Curses::KEY_PPAGE
          item_incr(-page_size)
        when Curses::KEY_BACKSPACE
          str.pop
          filter
        when (0..255)
          str << c.chr
          filter
        end
      end
    end
  end

  def shown_to
    shown_from + page_size
  end

  def page_size
    @screen.maxy - 2
  end

  def row(index = @selected)
    index - shown_from + 1
  end

  def select(index)
    render_item
    if index > shown_to
      render(index - shown_to + shown_from)
    elsif index < shown_from
      render(index)
    end
    @selected = index
    render_item index, true
  end

  def item_incr(incr)
    index = @selected + incr
    index = 0 if index < 0
    index = @matches.size - 1 unless index < @matches.size
    select index
  end

  def render_item(index = @selected, standout = false)
    Curses.setpos(row(index) , 0)
    @screen.clrtoeol
    Curses.standout if standout
    Curses.addstr @matches[index] unless @matches[index].nil?
    Curses.standend if standout
  end

  def render(from = 0)
    @shown_from = from
    (0..page_size).map { |y| render_item y + from }
  end

  def filter
    pattern = str.join
    @selected = 0
    @matches = @finder.sorted_matches_for pattern
    render @selected
    render_item @selected, true
  end

end

