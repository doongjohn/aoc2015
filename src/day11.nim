import std/strutils


proc incrementLowerCaseString(password: var string) =
  for i in countdown(password.high, 0):
    password[i] = (password[i].ord + 1).char
    if password[i] > 'z':
      password[i] = 'a'
    else:
      break


proc makeNextPassword(currentPassword: string): string =
  var password = currentPassword

  var ok = false
  while not ok:
    ok = true

    # increment string
    password.incrementLowerCaseString()

    # i, o, or l is not ok
    for c in password:
      if c in "iol":
        ok = false
        break

    if ok:
      # find abc, bcd, cde, and so on
      var found = false
      for i in 0 .. 5:
        if password[i].ord + 1 == password[i + 1].ord and
           password[i].ord + 2 == password[i + 2].ord:
            found = true
            break
      ok = found

    if ok:
      # find two different, non-overlapping pairs of letters
      var c = '\0'
      var i, n = 0
      while i < 7:
        defer: inc i
        if password[i] != c and password[i] == password[i + 1]:
          c = password[i]
          inc i
          inc n
      if n < 2:
        ok = false

  result = password


proc puzzle1* =
  var password = readFile("input/day11.txt").strip

  # print answer: vzbxxyzz
  echo password.makeNextPassword()


proc puzzle2* =
  var password = "vzbxxyzz"

  # print answer: vzcaabcc
  echo password.makeNextPassword()
