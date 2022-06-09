import std/streams
import std/sets

proc move(c: char, pos: var tuple[x, y: int]) =
  case c:
  of '^': inc pos.y
  of 'v': dec pos.y
  of '>': inc pos.x
  of '<': dec pos.x
  else:
    discard

proc puzzle1* =
  var visited = [(x: 0, y: 0)].toHashSet
  var pos = (x: 0, y: 0)
  var houses = 1

  # print answer
  defer: echo houses

  let inputs = openFileStream("input/day3.txt")
  defer: close inputs

  while peekChar(inputs) != '\0':
    let c = readChar(inputs)
    move(c, pos)

    if pos notin visited:
      visited.incl pos
      inc houses

proc puzzle2* =
  var visited = [(x: 0, y: 0)].toHashSet
  var posSanta = (x: 0, y: 0)
  var posRobot = (x: 0, y: 0)
  var turn = 0
  var houses = 1

  # print answer
  defer: echo houses

  let inputs = openFileStream("input/day3.txt")
  defer: close inputs

  while peekChar(inputs) != '\0':
    let c = readChar(inputs)
    defer: inc turn

    let posPtr =
      if turn mod 2 == 0:
        posSanta.addr
      else:
        posRobot.addr

    template pos: untyped = posPtr[]
    move(c, pos)

    if pos notin visited:
      visited.incl pos
      inc houses
