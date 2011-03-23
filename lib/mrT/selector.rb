require 'command-t/finder'

module MrT
  module Selector
    class << self
      def sources
        @sources ||= Hash.new
      end

      def /(code)
        me = self
        Class.new do
          include me
          extend ActionRegistry
          def self.desc(str = nil)
            @desc = str if str
            @desc
          end
          define_singleton_method(:inherited) { |sub| me.sources[code.to_s] = sub }
        end
      end
    end

    def pattern
      @pattern ||= []
    end

    def prompt
      ">> "
    end

    def items
      []
    end

    def selected(ui)
      ui.selected
    end

    def matcher(options = {})
      scanner = CommandT::Scanner.new
      scanner.instance_variable_set :@paths, items
      CommandT::Matcher.new scanner, options
    end

    def interact(ui)
      filter ui
      loop do
        ui.render_line 0, prompt, pattern.join
        ui.refresh
        case c = ui.getch
        when :escape
          return
        when :enter
          return selected ui
        when :backspace
          pattern.pop
          filter ui
        when :backslash
          chr = ui.getch
          src = Selector.sources[chr.chr] if Fixnum === chr
          if chr == :backslash
            pattern << "\\"
            filter ui
          elsif src
            return src.new.interact ui
          end
        when :tab
          action = action ui.dup
          action && action.execute(ui.close) || ui.redraw
        when (0..255)
          pattern << c.chr
          filter ui
        end
      end
    end

    def filter(ui)
      ui.show matcher.sorted_matches_for(pattern.join, {})
    end

    def action(ui)
      self.class.matching_actions_selector(selected(ui)).interact(ui)
    end
  end

  class Action
    attr_accessor :name, :desc, :guard, :action, :target

    def applies?
      if guard
        guard === target
      else
        target
      end
    end

    def execute(ui)
      ui.close
      action.call(ui, self)
    end
  end

  module ActionRegistry
    def actions
      @actions ||= []
    end

    def action(name, desc = nil, guard = lambda { |n| true }, &action)
      me = self
      cls = Class.new(Action) do
        define_method(:initialize) { |target|
          @name, @desc, @guard, @action, @target = name, desc, guard, action, target
        }
        define_singleton_method(:inherited) { |sub| me.actions << sub }
      end
      action && Class.new(cls) || cls
    end

    def matching_actions(obj)
      actions.map{ |c| c.new obj }.select(&:applies?)
    end

    def matching_actions_selector(obj)
      ActionSelector.new matching_actions(obj)
    end

    class ActionSelector
      include Selector

      def initialize(actions)
        @actions = actions
      end

      def items
        @items ||= @actions.map { |a| "%-15s %-30s" % [a.name, a.desc] }
      end

      def selected(ui)
        @actions[items.index(ui.selected)]
      end

      alias_method :action, :selected
    end
  end

  class SourceSelect < Selector/" "
    def items
      Selector.sources.map { |kv| "\\%-5s %-15s%-30s" % [kv.first, kv.last.name, kv.last.desc] }
    end

    def selected(ui)
      src = Selector.sources[ui.selected.split.first[1..-1]]
      if src
        src.new.interact ui
      else
        interact ui
      end
    end
  end

end
