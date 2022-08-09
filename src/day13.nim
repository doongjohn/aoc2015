import std/math
import std/streams
import std/strscans
import std/algorithm

proc puzzle1* =
  var inputs = openFileStream("input/day13.txt")
  defer: close inputs

  var result = 0

  # print answer: 618
  defer: echo result

  var pref: seq[seq[int]]
  var prevName = ""
  template addPerson =
    if pref.len == 0 or (pref.len > 0 and prevName != name):
      prevName = name
      pref.add @[]

  for line in lines(inputs):
    var name = ""
    var happiness = 0
    if line.scanf("$w would gain $i", name, happiness):
      addPerson()
      pref[^1].add happiness
    elif line.scanf("$w would lose $i", name, happiness):
      addPerson()
      pref[^1].add -happiness

  var index = [1, 2, 3, 4, 5, 6, 7]
  var all: array[8, int]

  template calcTotalHappiness: int =
    var total = 0
    all[1 .. ^1] = index
    for i, name in all:
      var right = all[floorMod(i + 1, 8)]
      var left = all[floorMod(i - 1, 8)]
      total += pref[name][(if name <= right: dec right; right)]
      total += pref[name][(if name <= left: dec left; left)]
    total

  while true:
    var total = calcTotalHappiness()
    if total > result: result = total
    if not index.nextPermutation():
      break

proc puzzle2* =
  # TODO: keep 7 factorial

  var inputs = openFileStream("input/day13.txt")
  defer: close inputs

  var result = 0

  # print answer: 601
  defer: echo result

  var pref: seq[seq[int]]
  pref.add @[0, 0, 0, 0, 0, 0, 0, 0] # add my self

  var prevName = ""
  template addPerson =
    if pref.len == 0 or (pref.len > 0 and prevName != name):
      prevName = name
      pref.add @[]
      pref[^1].add 0

  for line in lines(inputs):
    var name = ""
    var happiness = 0
    if line.scanf("$w would gain $i", name, happiness):
      addPerson()
      pref[^1].add happiness
    elif line.scanf("$w would lose $i", name, happiness):
      addPerson()
      pref[^1].add -happiness

  var index = [1, 2, 3, 4, 5, 6, 7, 8]
  var all: array[9, int]

  template calcTotalHappiness: int =
    var total = 0
    all[1 .. ^1] = index
    for i, name in all:
      var right = all[floorMod(i + 1, 9)]
      var left = all[floorMod(i - 1, 9)]
      total += pref[name][(if name <= right: dec right; right)]
      total += pref[name][(if name <= left: dec left; left)]
    total

  while true:
    var total = calcTotalHappiness()
    if total > result: result = total
    if not index.nextPermutation():
      break
