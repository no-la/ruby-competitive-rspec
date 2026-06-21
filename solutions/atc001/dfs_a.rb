# frozen_string_literal: true

module StateSpaceSearch
  class ConfigurationError < StandardError
  end

  class UnknownStrategyError < ArgumentError
  end

  class Problem
    attr_reader :goal_condition, :start_state, :transition_generator, :valid_condition

    def initialize
      @start_configured = false
      @valid_condition = ->(_state) { true }
    end

    def self.build(&definition)
      new.tap do |problem|
        problem.instance_eval(&definition)
      end
    end

    def start(state)
      @start_state = state
      @start_configured = true
    end

    def goal?(&condition)
      @goal_condition = condition
    end

    def transitions(&generator)
      @transition_generator = generator
    end

    def valid?(&condition)
      @valid_condition = condition
    end

    def solve_with(strategy)
      validate!
      searcher = { bfs: BFS, dfs: DFS }.fetch(strategy) do
        raise UnknownStrategyError, "unknown strategy: #{strategy.inspect}; expected :bfs or :dfs"
      end
      searcher.search(
        start: start_state,
        goal: goal_condition,
        transitions: transition_generator,
        valid: valid_condition
      )
    end

    private

    def validate!
      raise ConfigurationError, 'start is required' unless @start_configured
      raise ConfigurationError, 'goal? is required' unless goal_condition
      raise ConfigurationError, 'transitions is required' unless transition_generator
    end
  end

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
    def self.search(start:, goal:, transitions:, valid: ->(_state) { true })
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
          next unless valid.call(next_state)
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
    def self.search(start:, goal:, transitions:, valid: ->(_state) { true })
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
          next unless valid.call(next_state)
          next if visited[next_state]

          stack << [next_state, state, distance + 1]
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

# --- ここから前処理 ---

def search_problem(&)
  StateSpaceSearch::Problem.build(&)
end
DIRECTIONS = [
  [-1, 0],
  [1, 0],
  [0, -1],
  [0, 1]
].freeze

height, width = gets.split.map(&:to_i)
grid = Array.new(height) { gets.chomp.chars }

start_position = nil
goal_position = nil

grid.each_with_index do |row, y|
  row.each_with_index do |cell, x|
    start_position = [y, x] if cell == 's'
    goal_position = [y, x] if cell == 'g'
  end
end

# --- ここまで前処理 ---

problem = search_problem do
  start start_position
  goal? { |position| position == goal_position }

  transitions do |y, x|
    DIRECTIONS.map { |dy, dx| [y + dy, x + dx] }
  end

  valid? do |y, x|
    y.between?(0, height - 1) &&
      x.between?(0, width - 1) &&
      grid[y][x] != '#'
  end
end

result = problem.solve_with(:dfs)
puts result.reachable? ? 'Yes' : 'No'
