# frozen_string_literal: true

module StateSpaceSearch
  class Result
    attr_reader :distance, :parents, :path, :visit_order

    def initialize(reachable:, distance:, parents:, path:, visit_order:)
      @reachable = reachable
      @distance = distance
      @parents = parents
      @path = path
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
      distances = { start => 0 }
      parents = { start => nil }

      while head < queue.length
        state = queue[head]
        head += 1
        visit_order << state

        if goal.call(state)
          path = [state]
          path << parents.fetch(path.last) until path.last == start

          return Result.new(
            reachable: true,
            distance: distances.fetch(state),
            parents: parents,
            path: path.reverse,
            visit_order: visit_order
          )
        end

        transitions.call(state).each do |next_state|
          next if visited[next_state]

          visited[next_state] = true
          distances[next_state] = distances.fetch(state) + 1
          parents[next_state] = state
          queue << next_state
        end
      end

      Result.new(
        reachable: false,
        distance: nil,
        parents: parents,
        path: nil,
        visit_order: visit_order
      )
    end
  end

  class DFS
    def self.search(start:, goal:, transitions:)
      stack = [[start, nil, 0]]
      visited = {}
      visit_order = []
      parents = {}

      until stack.empty?
        state, parent, distance = stack.pop
        next if visited[state]

        visited[state] = true
        visit_order << state
        parents[state] = parent

        if goal.call(state)
          path = [state]
          path << parents.fetch(path.last) until path.last == start

          return Result.new(
            reachable: true,
            distance: distance,
            parents: parents,
            path: path.reverse,
            visit_order: visit_order
          )
        end

        transitions.call(state).reverse_each do |next_state|
          stack << [next_state, state, distance + 1] unless visited[next_state]
        end
      end

      Result.new(
        reachable: false,
        distance: nil,
        parents: parents,
        path: nil,
        visit_order: visit_order
      )
    end
  end
end
