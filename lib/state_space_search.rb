# frozen_string_literal: true

module StateSpaceSearch
  class Result
    attr_reader :visit_order

    def initialize(reachable, visit_order)
      @reachable = reachable
      @visit_order = visit_order
    end

    def reachable?
      @reachable
    end
  end

  class BFS
    def self.search(start:, goal:, transitions:)
      queue = [start]
      head = 0
      visited = { start => true }
      visit_order = []

      while head < queue.length
        state = queue[head]
        head += 1
        visit_order << state

        return Result.new(true, visit_order) if goal.call(state)

        transitions.call(state).each do |next_state|
          next if visited[next_state]

          visited[next_state] = true
          queue << next_state
        end
      end

      Result.new(false, visit_order)
    end
  end
end
