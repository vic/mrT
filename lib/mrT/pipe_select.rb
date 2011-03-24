module MrT
  class PipeSelect < Selector/''
    def items
      @items ||= items_from_argv || items_from_stdin
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
