import std/streams

proc puzzle1* =
  var inputs = openFileStream("input/day12.txt")
  defer: close inputs

  var sum = 0
  defer: echo sum

  var num = 0
  var sign = 1
  var isPrevNum = false
  var c: char
  while (c = inputs.readChar(); c) != '\0':
    if c in '0' .. '9':
      num *= 10
      num += c.ord - '0'.ord
      isPrevNum = true
    else:
      if isPrevNum:
        sum += num * sign
        num = 0
        sign = 1
      elif c == '-':
        sign = -1
      else:
        sign = 1
      isPrevNum = false

proc puzzle2* =
  # TODO: later
  var inputs = openFileStream("input/day12.txt")
  defer: close inputs
