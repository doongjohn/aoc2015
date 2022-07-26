import std/streams
import std/strformat
import std/parseutils

proc puzzle1* =
  var inputs = openFileStream("input/day12.txt")
  defer: close inputs

  var sum = 0

  # print answer: 111754
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

proc findInObject(input, find: string): int =
  result = -1
  let findstr = ":\"{find}\"".fmt
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
  # let input = """[1,{"a":{"a":1},"b":"red",{1}},1],{1,"a":"red"}"""

  var sum = 0

  # print answer: 65402
  defer: echo sum

  var i = 0
  while i < input.len:
    defer: inc i

    if input[i] in "{":
      let redObjEnd = input[i .. ^1].findInObject("red")
      if redObjEnd > 0:
        i += redObjEnd
        continue

    if input[i] == '-' or input[i] in '0' .. '9':
      var num = 0
      let numParsed = input.parseInt(num, i)
      if numParsed > 0:
        sum += num
        i += numParsed
