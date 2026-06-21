# frozen_string_literal: true

DIRECTIONS = [
  [-1, 0],
  [1, 0],
  [0, -1],
  [0, 1]
].freeze

height, width = $stdin.gets.split.map(&:to_i)
grid = Array.new(height) { $stdin.gets.chomp.chars }

start = nil
goal = nil

grid.each_with_index do |row, y|
  row.each_with_index do |cell, x|
    start = [y, x] if cell == 's'
    goal = [y, x] if cell == 'g'
  end
end

queue = [start]
head = 0
visited = Array.new(height) { Array.new(width, false) }
visited[start[0]][start[1]] = true

reachable = false

while head < queue.length
  y, x = queue[head]
  head += 1

  if [y, x] == goal
    reachable = true
    break
  end

  DIRECTIONS.each do |dy, dx|
    ny = y + dy
    nx = x + dx

    next if ny.negative? || ny >= height
    next if nx.negative? || nx >= width
    next if grid[ny][nx] == '#'
    next if visited[ny][nx]

    visited[ny][nx] = true
    queue << [ny, nx]
  end
end

puts(reachable ? 'Yes' : 'No')
