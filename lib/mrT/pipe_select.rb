module MrT
  class PipeSelect < Selector/''
    def items
      items_from_argv || items_from_stdin
    end

    def self.actions_from_argv(argv = MrT.cmd.argv)
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

    def interact(ui)
      filter ui
      if ui.items.size < 2 && actions.empty?
        ui.selected
      else
        super
      end
    end

    def prepare
      @actions, MrT.cmd.argv = self.class.actions_from_argv
      @pattern = MrT.cmd.argv.join.split(//)
      super
    end

    attr_reader :actions

    def items_from_argv
      rest = MrT.cmd.rest
      rest unless rest.empty?
    end

    def items_from_stdin
      STDIN.readlines.map(&:chomp).tap { STDIN.reopen '/dev/tty' }
    end
  end
end
