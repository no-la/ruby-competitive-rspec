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
    def self.search(start:, goal:, transitions:)
      queue = [start]
      head = 0
      visited = { start => true }

      while head < queue.length
        state = queue[head]
        head += 1

        return Result.new(true) if goal.call(state)

        transitions.call(state).each do |next_state|
          next if visited[next_state]

          visited[next_state] = true
          queue << next_state
        end
      end

      Result.new(false)
    end
  end
end
