proc puzzle1* =
  let input = readFile("input/day1.txt")
  var floor = 0

  # print answer
  defer: echo floor

  for c in input:
    case c:
    of '(': inc floor
    of ')': dec floor
    else:
      discard

proc puzzle2* =
  let input = readFile("input/day1.txt")
  var floor = 0
  var i = 0

  # print answer
  defer: echo i

  for c in input:
    defer: inc i
    case c:
    of '(':
      inc floor
    of ')':
      dec floor
      if floor < 0:
        break
    else:
      discard
