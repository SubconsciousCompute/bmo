# This is just an example to get you started. A typical hybrid package
# uses this file as the main entry point of the application.

import std/[logging, strutils]
import std/[options]
import std/[json]

import ./bmopkg/command
import ./bmopkg/install
import ./bmopkg/subcom

# initialize logger.
var logger = newConsoleLogger()
addHandler(logger)

proc subcom(groups: seq[string]): bool =
  ## Install tools group.
  for group in groups:
    discard installGroup(group)

proc where(names: seq[string], hints: seq[string] = @[],
    add_to_path: bool = false): string =
  ## Locate a binary and optionally add to path.
  var res: seq[string] = @[]
  for name in names:
    res &= get(findCommand(name, hints), "")
  return res.join("\n")

proc summary(): string =
  ## Summary of the system.
  var res = newJObject()
  res["install_command"] = %* installCommand("<pkgname>")
  return res.pretty

when isMainModule:
  import cligen
  dispatchMulti([where], [summary])
