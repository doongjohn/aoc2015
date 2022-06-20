import std/strutils
import std/strformat

func lookAndSay(input: string): string =
  # look and say
  #[
    1 becomes 11 (1 copy of digit 1).
    11 becomes 21 (2 copies of digit 1).
    21 becomes 1211 (one 2 followed by one 1).
    1211 becomes 111221 (one 1, one 2, and two 1s).
    111221 becomes 312211 (three 1s, two 2s, and one 1).
  ]#
  var curChar = input[0]
  var count = 0
  for c in input:
    if c == curChar:
      inc count
    else:
      result.add "{count}{curChar}".fmt
      curChar = c
      count = 1
  result.add "{count}{curChar}".fmt

proc puzzle1* =
  let input = readFile("input/day10.txt").strip

  var result = input

  # print result: 492982
  defer: echo result.len

  for _ in 0 ..< 40:
    result = lookAndSay(result)

proc puzzle2* =
  let input = readFile("input/day10.txt").strip

  var result = input

  # print result: 6989950
  defer: echo result.len

  for _ in 0 ..< 50:
    result = lookAndSay(result)
