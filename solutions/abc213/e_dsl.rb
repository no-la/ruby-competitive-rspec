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

def search_problem(&)
  StateSpaceSearch::Problem.build(&)
end

DIRS = [
  [-1, 0],
  [1, 0],
  [0, -1],
  [0, 1]
].freeze

def free_closure(seeds, height, width, passable)
  problem = search_problem do
    start [:seed_list, seeds]
    goal? { false }

    transitions do |state|
      if state[0] == :seed_list
        state[1]
      else
        y, x = state

        DIRS.filter_map do |dy, dx|
          ny = y + dy
          nx = x + dx
          next unless ny.between?(0, height - 1)
          next unless nx.between?(0, width - 1)
          next unless passable[[ny, nx]]

          [ny, nx]
        end
      end
    end

    valid? do |state|
      state[0].is_a?(Integer) &&
        state[1].is_a?(Integer) &&
        state[0].between?(0, height - 1) &&
        state[1].between?(0, width - 1) &&
        passable[[state[0], state[1]]]
    end
  end

  result = problem.solve_with(:bfs)
  result.visit_order.select { |state| state[0].is_a?(Integer) }
end

height, width = $stdin.gets.split.map(&:to_i)
grid = Array.new(height) { $stdin.gets.chomp.chars }
goal = [height - 1, width - 1]

passable = {}
grid.each_with_index do |row, y|
  row.each_with_index do |cell, x|
    passable[[y, x]] = true if cell == '.'
  end
end
passable[[0, 0]] = true

frontier = free_closure([[0, 0]], height, width, passable)
seen = {}
frontier.each do |state|
  seen[state] = true
  passable[state] = true
end
punches = 0

loop do
  if seen[goal]
    puts punches
    break
  end

  next_seeds = []
  added = {}

  frontier.each do |y, x|
    (-2..2).each do |dy|
      (-2..2).each do |dx|
        next if dy.abs == 2 && dx.abs == 2

        ny = y + dy
        nx = x + dx
        next unless ny.between?(0, height - 1)
        next unless nx.between?(0, width - 1)

        state = [ny, nx]
        next if seen[state]
        next if added[state]

        added[state] = true
        next_seeds << state
      end
    end
  end

  break if next_seeds.empty?

  punches += 1
  next_seeds.each { |state| passable[state] = true }
  frontier = free_closure(next_seeds, height, width, passable)
  frontier.each do |state|
    seen[state] = true
    passable[state] = true
  end
end
