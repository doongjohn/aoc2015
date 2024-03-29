import std/[
  streams,
  strformat,
  parseutils,
]


proc puzzle1* =
  var inputs = openFileStream("input/day12.txt")
  defer: close inputs

  var sum = 0

  # print answer: 111754
  defer: echo sum

  var num = 0
  var sign = 1
  var isPrevNum = false

  # read character by character
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


proc findValueInObject(input, value: string): int =
  result = -1 # --> end position of this object
              # result > 0 (found)
              # result = -1 (not found)

  let findstr = ":\"{value}\"".fmt
  let length = findstr.high

  var i = 0
  var level = 0
  var found = false
  while i < input.len:
    defer: inc i

    if input[i] in "{":
      inc level
    elif input[i] in "}":
      dec level
      if level == 0:
        if found:
          result = i
        break

    if level > 1 or found:
      continue

    if i + length < input.len and input[i .. i + length] == findstr:
      found = true


proc puzzle2* =
  let input = readFile("input/day12.txt")
  var sum = 0

  # print answer: 65402
  defer: echo sum

  var i = 0
  while i < input.len:
    defer: inc i

    # check if object contains "red"
    if input[i] in "{":
      let redObjEnd = input[i .. ^1].findValueInObject("red")
      if redObjEnd > 0:
        i += redObjEnd
        continue

    # parse int
    if input[i] == '-' or input[i] in '0' .. '9':
      var num = 0
      let numParsed = input.parseInt(num, i)
      if numParsed > 0:
        sum += num
        i += numParsed
