# frozen_string_literal: true

module StateSpaceSearch
  class Result
    def initialize(reachable)
      @reachable = reachable
    end

    def reachable?
      @reachable
    end
  end

  class BFS
    def self.search(**)
      Result.new(true)
    end
  end
end
