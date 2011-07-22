require 'command-t/ext' # CommandT::Matcher
require 'command-t/finder'

module CommandT
  # Finder for a predefined list of items provided at initialization
  class SimpleFinder < Finder
    attr_reader :paths

    def initialize(items, options = {})
      @paths = items
      @matcher = Matcher.new self, options
    end
  end
end
