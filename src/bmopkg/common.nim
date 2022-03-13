## Common utilities
##

import std/[os, osproc, strformat]
import std/[jsonutils, json, tables]

proc execute*(cmd: string, stopAtFailure: bool = true,
    workingDir: string = ""): string =
  ## Execute a mcommand and returns stdout + stderr.
  let r = execCmdEx(cmd, workingDir = workingDir)
  if stopAtFailure:
    doAssert r[1] == 0, fmt"Command did not succeed. `{cmd}`"
  result = r[0]


proc readEnvJson*(): JsonNode =
  ## Read environment variables.
  var env = initTable[string, string]()
  for (k, v) in envPairs():
    env[k] = v
  result = env.toJson


when isMainModule:
  import std/distros

  if detectOs(Windows):
    let x = execute("dir")
    echo x
    doAssert x.len > 0

  if detectOs(Linux):
    let x = execute("ls")
    echo x
    doAssert x.len > 0
