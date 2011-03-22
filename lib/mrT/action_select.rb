module MrT

  class ActionSelect
    def initialize(file)
      @file = file
    end

    attr_reader :ui

    def interact(ui)
      @ui = ui
      ui.render_line 0, "Action for: ", @file
      filter
      loop do
        case c = ui.getch
        when :escape, :shift_tab
          return
        end
      end
    end

    def filter
      ui.show matching_actions
    end

    def matching_actions
      ["vi", "dos", "emacs", "delete"]
    end
  end

end
