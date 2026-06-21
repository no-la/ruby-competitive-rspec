from collections import deque
import sys


DIRECTIONS = [(-1, 0), (1, 0), (0, -1), (0, 1)]


def main() -> None:
    input = sys.stdin.readline
    height, width = map(int, input().split())
    grid = [list(input().strip()) for _ in range(height)]

    start = None
    goal = None

    for y, row in enumerate(grid):
        for x, cell in enumerate(row):
            if cell == "s":
                start = (y, x)
            elif cell == "g":
                goal = (y, x)

    queue = deque([start])
    visited = [[False] * width for _ in range(height)]
    visited[start[0]][start[1]] = True

    while queue:
        y, x = queue.popleft()
        if (y, x) == goal:
            print("Yes")
            return

        for dy, dx in DIRECTIONS:
            ny = y + dy
            nx = x + dx

            if ny < 0 or ny >= height:
                continue
            if nx < 0 or nx >= width:
                continue
            if grid[ny][nx] == "#":
                continue
            if visited[ny][nx]:
                continue

            visited[ny][nx] = True
            queue.append((ny, nx))

    print("No")


if __name__ == "__main__":
    main()
