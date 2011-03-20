require 'curses'
require 'command-t/finder'

class MrT

  attr_reader :str, :shown_from, :pwd

  def initialize(pwd)
    @str = []
    @options = {
    }
    @pwd = pwd
    @finder = CommandT::Finder.new @pwd, @options
  end

  def run
    value = with_curses { interact }
    File.expand_path(value, @pwd) if value
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

