import std/intsets

proc puzzle1* =
  var nice = 0

  # print answer
  defer: echo nice

  for line in lines("input/day5.txt"):
    block loop:
      var doubleLetter = false
      var vowelCout = 0

      for i, c in line:
        if i < line.high:
          # check banned strings
          if line[i .. i + 1] in ["ab", "cd", "pq", "xy"]:
            break loop

          # check consecutive
          if c == line[i + 1]:
            doubleLetter = true

        # check vowels
        if c in "aeiou":
          inc vowelCout

      if doubleLetter and vowelCout > 2:
        inc nice

proc puzzle2* =
  var nice = 0

  # print answer
  defer: echo nice

  for line in lines("input/day5.txt"):
    var rule1 = false
    var rule2 = false

    var pairs = initIntSet()
    var prevPair = 0
    template pairToInt(a, b: char): int =
      a.int * 1000 + b.int

    for i, c in line:
      # check rule1
      if not rule1 and i < line.high:
        let hash = pairToInt(c, line[i + 1])
        if hash in pairs and hash != prevPair:
          rule1 = true
        pairs.incl hash
        prevPair = if hash == prevPair: 0 else: hash

      # check rule2
      if not rule2 and i < line.high - 1:
        if c == line[i + 2]:
          rule2 = true

      if rule1 and rule2:
        inc nice
        break
