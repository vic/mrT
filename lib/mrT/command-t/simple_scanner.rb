require 'command-t/scanner'

module CommandT
  # Scanner for a predefined list of items provided at initialization
  class SimpleScanner < Scanner
    attr_reader :paths

    def initialize(items = [])
      @paths = items
    end
  end
end
