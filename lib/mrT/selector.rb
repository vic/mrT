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

    def memoized_items
      @items ||= items
    end

    def prepare
      @actions = MrT.cmd.actions if MrT.cmd.actions
      @pattern = MrT.cmd.pattern if MrT.cmd.pattern
      memoized_items
    end

    def prepared?
      !(@items.nil? || @items.empty?)
    end

    def items
      []
    end

    def selected(ui)
      ui.selected
    end

    def matcher(options = {})
      scanner = CommandT::Scanner.new
      scanner.instance_variable_set :@paths, memoized_items
      CommandT::Matcher.new scanner, options
    end

    def interact(ui)
      filter ui
      return selected ui if ui.items.size < 2 && actions.empty?
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
          return action(ui.dup).execute(ui)
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
      item = selected(ui)
      if (actions = matching_actions(item)).empty?
        Action.new.tap { |a| a.action = lambda { |u,a| item } }
      else
        ActionRegistry::ActionSelector.new(actions).interact(ui)
      end
    end

    def actions
      @actions ||= self.class.actions
    end

    def matching_actions(obj)
      actions.map{ |c| c.new obj }.select(&:applies?)
    end
  end

  class Action
    attr_accessor :name, :desc, :guard, :action, :target

    def applies?
      if guard.respond_to?(:call)
        guard.call(target)
      elsif guard
        guard === target
      else
        target
      end
    end

    def execute(ui)
      ui.close
      prc = String === action && Action.cmd_proc(action) || action
      prc.call(ui, self)
    end

    def self.with(name, desc, action, guard = lambda { |n| true})
      Class.new(self) do
        define_method(:initialize) { |target|
          @name, @desc, @action, @guard, @target = name, desc, action, guard, target
        }
      end
    end

    def self.cmd_proc(str)
      lambda do |ui, action|
        target = action.target
        ary = [target, target.split].flatten.compact
        pos = []
        str, knd = str.split(':',2).reverse
        knd = 'shell' unless %w(shell system exec spawn eval echo puts).include? knd
        cmd = str.gsub(/(\\)?%(\d+)(:)?/) do |txt|
          if $1
            '%' + $2 + $3
          else
            pos << ary[$2.to_i]
            $3 && '%' || '%s'
          end
        end
        mth = {'shell' => 'system', 'echo' => 'puts'}[knd] || knd
        Kernel.send(mth, cmd % pos).tap do
          exit $?.exitstatus if knd =~ /spawn|shell|echo|puts/
        end
      end
    end
  end

  module ActionRegistry
    def actions
      @actions ||= []
    end

    def action(name, desc = nil, guard = lambda { |n| true }, &action)
      me = self
      cls = Action.with(name, desc, action, guard)
      cls.define_singleton_method(:inherited) { |sub| me.actions << sub }
      action && Class.new(cls) || cls
    end

    class ActionSelector
      include Selector

      def initialize(actions)
        @actions = actions
      end

      def items
        @actions.map { |a| "%-15s %-30s" % [a.name, a.desc] }
      end

      def selected(ui)
        @actions[memoized_items.index(ui.selected)]
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
