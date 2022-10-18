import std/[
  strutils,
  md5,
]


proc puzzle1* =
  let input = readFile("input/day4.txt").strip
  var answer = 1

  # print answer
  defer: echo answer - 1

  var hash = getMD5(input)
  while not hash.startsWith('0'.repeat(5)):
    hash = getMD5(input & $answer)
    inc answer


proc puzzle2* =
  let input = readFile("input/day4.txt").strip
  var answer = 1

  # print answer
  defer: echo answer - 1

  var hash = getMD5(input)
  while not hash.startsWith('0'.repeat(6)):
    hash = getMD5(input & $answer)
    inc answer
