import std/strscans
import std/strutils

type
  Grid[T] = array[1000, array[1000, T]]

  Pos = tuple[x, y: int]

iterator iterAll[T](grid: var Grid[T]): var T =
  for y in 0 ..< 1000:
    for x in 0 ..< 1000:
      yield grid[y][x]

iterator iterSquareArea[T](grid: var Grid[T], p1, p2: Pos): var T =
  # p1: top left
  # p2: bottom right
  for y in p1.y .. p2.y:
    for x in p1.x .. p2.x:
      yield grid[y][x]

proc puzzle1* =
  const commands = ["turn on", "turn off", "toggle"]
  var grid: Grid[bool]

  # print answer
  defer:
    var lights = 0
    for e in grid.iterAll:
      if e: inc lights
    echo lights

  for line in lines("input/day6.txt"):
    var offset: int
    for cmd in commands:
      if line.startsWith(cmd):
         offset = cmd.len
         break

    var p1, p2: Pos
    if line[offset + 1 .. ^1].scanf(
      "$i,$i through $i,$i",
      p1.x, p1.y, p2.x, p2.y
    ):
      case offset:
      # turn on
      of commands[0].len:
        for e in grid.iterSquareArea(p1, p2):
          e = true
      # turn off
      of commands[1].len:
        for e in grid.iterSquareArea(p1, p2):
          e = false
      # toggle
      of commands[2].len:
        for e in grid.iterSquareArea(p1, p2):
          e = not e
      else:
        discard

proc puzzle2* =
  const commands = ["turn on", "turn off", "toggle"]
  var grid: Grid[int]

  # print answer
  defer:
    var lights = 0
    for e in grid.iterAll:
      lights += e
    echo lights

  for line in lines("input/day6.txt"):
    var offset: int
    for cmd in commands:
      if line.startsWith(cmd):
         offset = cmd.len
         break

    var p1, p2: Pos
    if line[offset + 1 .. ^1].scanf(
      "$i,$i through $i,$i",
      p1.x, p1.y, p2.x, p2.y
    ):
      case offset:
      # turn on
      of commands[0].len:
        for e in grid.iterSquareArea(p1, p2):
          inc e
      # turn off
      of commands[1].len:
        for e in grid.iterSquareArea(p1, p2):
          e = max(0, e - 1)
      # toggle
      of commands[2].len:
        for e in grid.iterSquareArea(p1, p2):
          e += 2
      else:
        discard
