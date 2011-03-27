require 'command-t/ext' # CommandT::Matcher
require 'command-t/finder'
require 'mrT/command-t/simple_scanner'

module CommandT
  # Finder for a predefined list of items provided at initialization
  class SimpleFinder < Finder
    def initialize(items, options = {})
      @scanner = SimpleScanner.new items
      @matcher = Matcher.new @scanner, options
    end
  end
end
