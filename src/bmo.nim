# This is just an example to get you started. A typical hybrid package
# uses this file as the main entry point of the application.

import std/[logging, strutils, sequtils]
import std/[options]

import std/[json, marshal]

import ./bmopkg/command
import ./bmopkg/install
import ./bmopkg/subcom

# initialize logger.
var logger = newConsoleLogger(levelThreshold = lvlInfo, useStdErr = true,
    fmtStr = "[$time] - $levelname: ")
addHandler(logger)

proc install_subcom(groups: seq[string]): bool =
  ## Install tools group.
  for group in groups:
    discard installGroup(group)

proc install(pkgnames: seq[string]): bool =
  ## Install tools group.
  for pkgname in pkgnames:
    discard installPackage(pkgname)

proc listInstalled(json: bool = false): string =
  let ls = listInstalledPkgs()
  if json:
    result = $$ls
  else:
    result = ls.mapIt(it.toTxt).join("\n")

proc where(names: seq[string], hints: seq[string] = @[],
    add_to_path: bool = false): string =
  ## Locate a binary and optionally add to path.
  var res = newJObject()
  for name in names:
    res[name] = %* get(findCommand(name, hints), "")
  return res.pretty

proc summary(): string =
  ## Summary of the system.
  var res = newJObject()
  res["commands"] = %* pkgManagerCommands()
  return res.pretty

#
# Main module.
#
when isMainModule:
  import cligen
  dispatchMulti([where], [summary], [list_installed])
