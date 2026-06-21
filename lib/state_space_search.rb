# frozen_string_literal: true

module StateSpaceSearch
  class Result
    attr_reader :distance, :parents, :visit_order

    def initialize(reachable, visit_order, distance, parents)
      @reachable = reachable
      @visit_order = visit_order
      @distance = distance
      @parents = parents
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
      distances = { start => 0 }
      parents = { start => nil }

      while head < queue.length
        state = queue[head]
        head += 1
        visit_order << state

        return Result.new(true, visit_order, distances.fetch(state), parents) if goal.call(state)

        transitions.call(state).each do |next_state|
          next if visited[next_state]

          visited[next_state] = true
          distances[next_state] = distances.fetch(state) + 1
          parents[next_state] = state
          queue << next_state
        end
      end

      Result.new(false, visit_order, nil, parents)
    end
  end
end
