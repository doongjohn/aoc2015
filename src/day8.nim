proc puzzle1* =
  var result = 0

  # print result
  defer: echo result

  for line in lines("input/day8.txt"):
    var actual = 0
    var i = 1
    while i < line.high and line[i] != '\n':
      inc actual
      if line[i] == '\\':
        if line[i + 1] == 'x':
          i += 4
        else:
          i += 2
      else:
        inc i
    result += line.len - actual

proc puzzle2* =
  var result = 0

  # print result
  defer: echo result

  for line in lines("input/day8.txt"):
    var actual = 0
    var i = 0
    while i < line.len and line[i] != '\n':
      inc actual
      if line[i] in ['\\', '\"']:
        inc actual
      inc i
    # add 2 for the opening and closing "
    result +=  actual + 2 - line.len
