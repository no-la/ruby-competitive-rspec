# frozen_string_literal: true

class Deque
  def initialize
    @front = []
    @back = []
  end

  def empty?
    @front.empty? && @back.empty?
  end

  def push_front(value)
    @front << value
  end

  def push_back(value)
    @back << value
  end

  def pop_front
    refill_front if @front.empty?
    @front.pop
  end

  private

  def refill_front
    return if @back.empty?

    @front = @back.reverse
    @back = []
  end
end

DIRS = [
  [-1, 0],
  [1, 0],
  [0, -1],
  [0, 1]
].freeze

HEIGHT, WIDTH = STDIN.gets.split.map(&:to_i)
GRID = Array.new(HEIGHT) { STDIN.gets.chomp.chars }
INF = 1 << 60

dist = Array.new(HEIGHT) { Array.new(WIDTH, INF) }
dist[0][0] = 0

queue = Deque.new
queue.push_front([[0, 0], 0])

until queue.empty?
  (y, x), current = queue.pop_front

  next if current != dist[y][x]
  break if y == HEIGHT - 1 && x == WIDTH - 1

  DIRS.each do |dy, dx|
    ny = y + dy
    nx = x + dx
    next unless ny.between?(0, HEIGHT - 1)
    next unless nx.between?(0, WIDTH - 1)
    next unless GRID[ny][nx] == '.'

    next_distance = current
    next if next_distance >= dist[ny][nx]

    dist[ny][nx] = next_distance
    queue.push_front([[ny, nx], next_distance])
  end

  (-2..2).each do |dy|
    (-2..2).each do |dx|
      next if dy.abs == 2 && dx.abs == 2

      ny = y + dy
      nx = x + dx
      next unless ny.between?(0, HEIGHT - 1)
      next unless nx.between?(0, WIDTH - 1)

      next_distance = current + 1
      next if next_distance >= dist[ny][nx]

      dist[ny][nx] = next_distance
      queue.push_back([[ny, nx], next_distance])
    end
  end
end

puts dist[HEIGHT - 1][WIDTH - 1]
