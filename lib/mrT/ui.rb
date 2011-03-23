require 'curses'
require 'readline'

module MrT

  class UI

    KEYCODES = {
      9 => :tab,
      353 => :shift_tab,
      13 => :enter,
      27 => :escape,
      92 => :backslash,
      Curses::KEY_ENTER => :enter,
      Curses::KEY_BACKSPACE => :backspace
    }

    def show(items, selected = 0)
      @items = items
      @selected = selected
      render @selected
      render_item @selected, true
    end

    attr_accessor :shown_from, :items

    def goto(line = 0, col = 0)
      Curses.setpos line, col
    end

    def render_line(index = 0, *text)
      Curses.setpos(index, 0)
      @screen.clrtoeol
      text.each do |txt|
        case txt
        when String
          Curses.addstr(txt)
        when :standout, :standend
          Curses.send(txt)
        end
      end
    end

    def getch
      loop do
        c = Curses.getch
        c = c.ord if c.respond_to?(:ord)
        case c
        when Curses::KEY_RIGHT #, 9 # TAB
          item_incr(10)
        when Curses::KEY_LEFT # , 353 # SHIT-TAB
          item_incr(-10)
        when Curses::KEY_UP, Curses::KEY_CTRL_P
          item_incr(-1)
        when Curses::KEY_DOWN, Curses::KEY_CTRL_N
          item_incr(1)
        when Curses::KEY_NPAGE
          item_incr(page_size)
        when Curses::KEY_PPAGE
          item_incr(-page_size)
        else
          return KEYCODES[c] || c
        end
      end
    end

    def clear
      @screen.clear
    end

    def redraw
      render shown_from
      render_item(@selected, true)
      refresh
    end

    def refresh
      @screen.refresh
    end

    def ungets(str)
      str.reverse.each_char { |c| Curses.ungetch c }
    end

    def gets
      teardown
      Curses.getstr
    ensure
      setup
    end

    def readline(prompt, cloze = true, reopen = true)
      close if cloze
      Readline::readline(prompt, true)
    ensure
      if reopen
        open; redraw
      end
    end

    def open
      Curses.init_screen
      @screen = Curses.stdscr
      setup
    end

    def close
     Curses.close_screen
    end

    def setup
      Curses.nonl
      Curses.cbreak
      Curses.noecho
      @screen.scrollok true
      @screen.keypad true
    end

    def teardown
      @screen.scrollok false
      @screen.keypad false
      Curses.echo
      Curses.nocbreak
      Curses.nl
    end

    def with_curses
      open
      begin
        yield
      rescue Interrupt
        close
      ensure
        close
      end
    end

    def selected
      items[@selected]
    end

    def selected_index
      items.index selected
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
      index = @items.size - 1 unless index < @items.size
      select index
    end

    def render_item(index = @selected, standout = false)
      render_line(row(index),
                  standout && :standout,
                  @items[index],
                  standout && :standend)
    end

    def render(from = 0)
      @shown_from = from
      (0..page_size).map { |y| render_item y + from }
    end

  end

end
