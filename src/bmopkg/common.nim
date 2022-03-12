## Common utilities
##

import std/[osproc, strformat]

proc execute*(cmd: string, stopAtFailure: bool = true,
    workingDir: string = ""): string =
  ## Execute a mcommand and returns stdout + stderr.
  let r = execCmdEx(cmd, workingDir=workingDir)
  if stopAtFailure:
    doAssert r[1] == 0, fmt"Command did not succeed. `{cmd}`"
  result = r[0]


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
