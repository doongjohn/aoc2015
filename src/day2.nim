import std/strscans


proc puzzle1* =
  var total = 0

  # print answer
  defer: echo total

  for line in lines("input/day2.txt"):
    var l, w, h: int
    if line.scanf("$ix$ix$i", l, w, h):
      let s1 = l * w
      let s2 = w * h
      let s3 = h * l
      total += 2 * (s1 + s2 + s3)
      total += min([s1, s2, s3])


proc puzzle2* =
  var total = 0

  # print answer
  defer: echo total

  for line in lines("input/day2.txt"):
    var l, w, h: int
    if line.scanf("$ix$ix$i", l, w, h):
      let p1 = l + w
      let p2 = w + h
      let p3 = h + l
      total += 2 * min([p1, p2, p3])
      total += l * w * h
