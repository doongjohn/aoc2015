import std/[
  sets,
  tables,
  strscans,
  strformat,
]

# idea
# 1. get all the possible path that visits all nodes
# 2. get the shortest path among those

# TODO: learn from others
# https://www.reddit.com/r/adventofcode/comments/3w192e/day_9_solutions/


type Node = tuple
  name: string
  dist: int


func getDistance(graph: Table[string, seq[Node]], a, b: string): int =
  for (name, dist) in graph[a]:
    if name == b:
      return dist


proc getAllSimplePath(graph: Table[string, seq[Node]], source, dest: string): seq[seq[string]] =
  var visited = initHashSet[string]()
  var localPath = newSeq[string]()

  # TODO: change this code to iterative
  # code reference: https://www.geeksforgeeks.org/find-paths-given-source-destination/
  proc rec(graph: Table[string, seq[Node]], source, dest: string, localPath: var seq[string], result: var seq[seq[string]]) =
    if source == dest:
      # add to the result if this path visits all nodes
      if localPath.len == graph.len - 1:
        result.add localPath
      return

    visited.incl source

    for next in graph[source]:
      if next.name notin visited:
        localPath.add next.name
        rec(graph, next.name, dest, localPath, result)
        discard localPath.pop()

    visited.excl source

  rec(graph, source, dest, localPath, result)


proc parseInputData(graph: var Table[string, seq[Node]]) =
  const testInput = [
    "London to Dublin = 464",
    "London to Belfast = 518",
    "Dublin to Belfast = 141"
  ]

  # for line in testInput:
  for line in lines("input/day9.txt"):
    var a, b: string
    var dist: int
    if line.scanf("$+ to $+ = $i", a, b, dist):
      if not graph.hasKey(a): graph[a] = @[(b, dist)] else: graph[a].add (b, dist)
      if not graph.hasKey(b): graph[b] = @[(a, dist)] else: graph[b].add (a, dist)


proc puzzle1* =
  # adjacency list
  var graph = initTable[string, seq[Node]]()
  graph.parseInputData()

  var result = int.high

  # print result: 117
  defer: echo result

  for root in graph.keys:
    # echo "from: {root}".fmt
    for next in graph.keys:
      if next != root:
        let paths = graph.getAllSimplePath(root, next)
        # echo paths

        for path in paths:
          var distance = graph.getDistance(root, path[0])
          for i in 1 .. path.high:
            distance += graph.getDistance(path[i - 1], path[i])

          # echo distance
          if result > distance:
            result = distance


proc puzzle2* =
  # adjacency list
  var graph = initTable[string, seq[Node]]()
  graph.parseInputData()

  var result = 0

  # print result: 909
  defer: echo result

  for root in graph.keys:
    # echo "from: {root}".fmt
    for next in graph.keys:
      if next != root:
        let paths = graph.getAllSimplePath(root, next)
        # echo paths

        for path in paths:
          var distance = graph.getDistance(root, path[0])
          for i in 1 .. path.high:
            distance += graph.getDistance(path[i - 1], path[i])

          # echo distance
          if result < distance:
            result = distance
