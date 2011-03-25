module MrT
  class PipeSelect < Selector/''
    def items
      items_from_argv || items_from_stdin
    end

    def self.actions_from_argv(argv = MrT.cmd.argv)
      idx, actions = -1, Array.new
      while arg = argv[idx += 1]
        next unless arg =~ /^--[^-]/
        name, desc = arg[2..-1].split(':', 2)
        cmd = argv[idx + 1]
        cmd = nil if cmd =~ /^--[^-]/
        idx += 1 if cmd
        action = cmd || "exec:#{name} %0"
        actions << Action.with(name, desc, action)
      end
      actions
    end

    def actions
      self.class.actions_from_argv
    end

    def items_from_argv
      rest = MrT.cmd.rest
      rest unless rest.empty?
    end

    def items_from_stdin
      STDIN.readlines.map(&:chomp).tap { STDIN.reopen '/dev/tty' }
    end
  end
end
