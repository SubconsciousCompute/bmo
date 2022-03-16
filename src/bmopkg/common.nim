## Common utilities
##

import std/[os, logging, osproc, strutils, strformat]
import std/[jsonutils, json, tables]

proc executeBlocking*(cmd: string, stopAtFailure: bool = true,
    workingDir: string = ""): string =
  ## Execute a mcommand and returns stdout + stderr.
  info(fmt"> Executing '{cmd}'")
  let r = execCmdEx(cmd, workingDir = workingDir)
  if stopAtFailure:
    doAssert r[1] == 0, &"Command `{cmd}` did not succeed.\n\n\tOutput:\n{r[0]}"
  result = r[0]

proc execute*(cmd: string, stopAtFailure: bool = true,
    workingDir: string = "", timeout: int = 120): string =
  ## Execute a mcommand and returns stdout + stderr.
  info(fmt"> Executing '{cmd}'. Timeout {timeout} sec")
  let fs = cmd.splitWhiteSpace
  let p = startProcess(fs[0], workingDir = workingDir, args=fs[1..^1])
  for line in p.lines:
    debug(fmt"{fs[0]}: {line}")
    result &= line & '\n'
  let st = waitForExit(p, timeout)
  if stopAtFailure:
    doAssert st == 0, fmt"Command `{cmd}` did not succeed."


proc readEnvJson*(): JsonNode =
  ## Read environment variables.
  var env = initTable[string, string]()
  for (k, v) in envPairs():
    env[k] = v
  result = env.toJson


when isMainModule:
  import std/distros

  echo("\n\n====\nModule tests")
  if detectOs(Windows):
    echo ">> Execute dir\n"
    let x = execute("dir")
    doAssert x.len > 0

  if detectOs(Linux):
    let x = execute("ls")
    echo x
    doAssert x.len > 0
