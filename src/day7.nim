import std/algorithm
import std/options
import std/strformat
import std/strutils

type
  StringView = openArray[char]

  ParseResult[T] = tuple
    read: int
    value: T

  Operator {.pure.} = enum
    bitNot
    bitAnd
    bitOr
    bitLShift
    bitRShift

  OperandKind {.pure.} = enum
    number
    id

  Operand = object
    kind: OperandKind
    val: uint16

proc idToIndex(id: StringView): uint16 {.inline.} =
  if id.len == 1:
    result = id[0].uint16 - 96.uint16
  elif id.len == 2:
    result = (id[0].uint16 - 96.uint16) * 100 + (id[1].uint16 - 96.uint16)
  else:
    # this is impossible because the max length of the `wire id` is 2
    result = 0

proc indexToId(index: SomeInteger): string {.inline.} =
  if index > 99:
    result.add ((index div 100) + 96).char
    result.add ((index mod 100) + 96).char
  else:
    result.add (index + 96).char

template getValueOf(valueMap: typed, id: openArray[char]): untyped =
  valueMap[id.idToIndex]

# get the actual value of the `Operand`
template get(operand: Operand, table: typed): Option[uint16] =
  case operand.kind:
  of OperandKind.id:
    table[operand.val]
  of OperandKind.number:
    some operand.val

# convert `Operand` to string representation
proc `$`(operand: Operand): string =
  case operand.kind:
  of OperandKind.id:
    operand.val.indexToId
  of OperandKind.number:
    $operand.val

# similar to std/parseutils `parseInt` but simpler and generic
proc parseInteger[T: SomeInteger](str: StringView, num: var T): int =
  num = 0
  for c in str:
    if c notin '0' .. '9': return
    num = num * 10 + (c.ord - '0'.ord).T
    inc result

proc parseOperand(input: StringView): ParseResult[Operand] =
  # parse number literal
  if input[0] in '0' .. '9':
    var num: uint
    result.read = input.parseInteger(num) + 1
    result.value = Operand(kind: OperandKind.number, val: num.uint16)
    return

  # parse wire id
  if input[0] in 'a' .. 'z':
    result.read = input.find(' ') + 1
    if result.read == 0:
      result.read = input.len + 1
    let val = input.toOpenArray(0, result.read - 2).idToIndex
    result.value = Operand(kind: OperandKind.id, val: val)
    return

proc parseOperator(input: StringView): ParseResult[Operator] =
  for i, op in [ "NOT", "AND", "OR", "LSHIFT", "RSHIFT" ]:
    if input.toOpenArray(0, op.high) == op:
      return (op.len + 1, i.Operator)

# parse string from `0` to `str.high`
template parseWhole(str: StringView, parseProc: typed): untyped =
  let (read, value) = parseProc str
  if read < str.len:
    return
  value

# parse string from `pos`
template parse(str: StringView, pos: int, parseProc: typed): untyped =
  let (read, value) = parseProc str.toOpenArray(pos, str.high)
  if read != 0 and pos + read < str.len:
    pos += read
  else:
    return
  value

# parse string from `pos` to `str.high`
template parseLast(str: StringView, pos, parseProc: typed): untyped =
  let (read, value) = parseProc str.toOpenArray(pos, str.high)
  if pos + read < str.len:
    return
  value

proc parseInstrAssign(str: string): Option[Operand] =
  let operand = str.parseWhole(parseOperand)
  result = some operand

proc parseInstrPrefix(str: StringView): Option[tuple[op: Operator, target: Operand]] =
  var pos = 0
  let operator = str.parse(pos, parseOperator)
  let operand = str.parseLast(pos, parseOperand)
  result = some (operator, operand)

proc parseInstrInfix(str: StringView): Option[tuple[op: Operator, lhs, rhs: Operand]] =
  var pos = 0
  let lhs = str.parse(pos, parseOperand)
  let operator = str.parse(pos, parseOperator)
  let rhs = str.parseLast(pos, parseOperand)
  result = some (operator, lhs, rhs)

template runInstrAssign(
  instr: Operand,
  valueMap: typed,
  i: SomeInteger,
) =
  let operand = instr
  let val = operand.get valueMap
  if val.isSome:
    valueMap[i] = val

template runInstrPrefix(
  instr: tuple[op: Operator, target: Operand],
  valueMap: typed,
  i: SomeInteger,
) =
  let (op, operand) = instr
  let val = operand.get valueMap
  if val.isSome:
    let val = val.get
    valueMap[i] = case op:
    of Operator.bitNot:
      some not val
    else:
      none uint16

template runInstrInfix(
  instr: tuple[op: Operator, lhs, rhs: Operand],
  valueMap: typed,
  i: SomeInteger,
) =
  let (op, lhs, rhs) = instr
  let valL = lhs.get valueMap
  let valR = rhs.get valueMap
  if valL.isSome and valR.isSome:
    let valL = valL.get
    let valR = valR.get
    valueMap[i] = case op:
    of Operator.bitAnd:
      some valL and valR
    of Operator.bitOr:
      some valL or valR
    of Operator.bitLShift:
      some valL shl valR
    of Operator.bitRShift:
      some valL shr valR
    else:
      none uint16

proc puzzle1* =
  # this list contains all `wire index` that is used
  var wireIndices: seq[uint16]

  # TODO: think about dependency resolution
  # var deps: seq[]

  # this array contains values of the wire
  # the index is the `wire id`
  # a ~ zz (1 ~ 2626)
  const listLen = "zz".idToIndex + 1
  var values: array[listLen, Option[uint16]]

  # print answer: 956
  defer:
    let a = values.getValueOf("a").get
    echo "{a = }".fmt

  # these arrays contain all operations
  # the index is the `wire id`
  var instrListAssign: array[listLen, Option[Operand]]
  var instrListPrefix: array[listLen, Option[tuple[op: Operator, target: Operand]]]
  var instrListInfix: array[listLen, Option[tuple[op: Operator, lhs, rhs: Operand]]]

  # helper template
  template tryParseInstr(instrStr: StringView, op: untyped) =
    block:
      let res = instrStr.`parseInstr op`
      if res.isSome:
        `instrList op`[wireIndex] = res
        wireIndices.add wireIndex
        continue

  # parse input file and populate `listOp`
  for line in lines("input/day7.txt"):
    let line = line.strip
    let arrow = line.rfind('>')
    let instrStr = line[0 .. arrow - 3]
    let wireId = line[arrow + 2 .. ^1]
    let wireIndex = wireId.idToIndex
    instrStr.tryParseInstr Assign
    instrStr.tryParseInstr Prefix
    instrStr.tryParseInstr Infix

  # sort indices for less cache misses
  wireIndices.sort()

  # helper template
  template tryRunInstr(op: untyped) =
    for i in wireIndices:
      if values[i].isNone:
        let instr = `instrList op`[i]
        if instr.isSome:
          `runInstr op`(instr.get, values, i)

  # loop until wire `a` has a value
  # HACK: optimize this
  while values[1].isNone:
    tryRunInstr Assign
    tryRunInstr Prefix
    tryRunInstr Infix

proc puzzle2* =
  # this list contains all `wire index` that is used
  var wireIndices: seq[uint16]

  # this array contains values of the wire
  # the index is the `wire id`
  # a ~ zz (1 ~ 2626)
  const listLen = "zz".idToIndex + 1
  var values: array[listLen, Option[uint16]]

  # print answer: 40149
  defer:
    let a = values.getValueOf("a").get
    echo "{a = }".fmt

  # these arrays contain all operations
  # the index is the `wire id`
  var instrListAssign: array[listLen, Option[Operand]]
  var instrListPrefix: array[listLen, Option[tuple[op: Operator, target: Operand]]]
  var instrListInfix: array[listLen, Option[tuple[op: Operator, lhs, rhs: Operand]]]

  # helper template
  template tryParseInstr(instrStr: StringView, op: untyped) =
    block:
      let res = instrStr.`parseInstr op`
      if res.isSome:
        `instrList op`[wireIndex] = res
        wireIndices.add wireIndex
        continue

  # parse input file and populate `listOp`
  for line in lines("input/day7.txt"):
    let line = line.strip
    let arrow = line.rfind('>')
    var instrStr = line[0 .. arrow - 3]
    let wireId = line[arrow + 2 .. ^1]
    if wireId == "b":
      instrStr = "956" # replace instruction of the wire `b`
    let wireIndex = wireId.idToIndex
    instrStr.tryParseInstr Assign
    instrStr.tryParseInstr Prefix
    instrStr.tryParseInstr Infix

  # sort indices for less cache misses
  wireIndices.sort()

  # helper template
  template tryRunInstr(op: untyped) =
    for i in wireIndices:
      if values[i].isNone:
        let instr = `instrList op`[i]
        if instr.isSome:
          `runInstr op`(instr.get, values, i)

  # loop until wire `a` has a value
  # HACK: optimize this
  while values[1].isNone:
    tryRunInstr Assign
    tryRunInstr Prefix
    tryRunInstr Infix
