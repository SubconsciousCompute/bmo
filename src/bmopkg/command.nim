## Command module.
##
## Author: Dilawar Singh <dilawar@subcom.tech>
## See the output of `git blame` as well.

import std/[os, strformat, distros, sequtils, options, logging]

from std/strutils import endsWith

import itertools

import ./install

proc findCommand*(name: string, hints: openArray[string] = @[]): Option[string] =
  ##
  ## Search for a given command (in the list of directories).
  ##
  ## If not found in PATH, try finding it in the given list of directories.
  ##
  ## Return some(path) on success. None otherwise.
  ##
  var cmd: string = name
  if defined(Windows) and not cmd.endsWith(".exe"):
    cmd = cmd & ".exe"

  # if the given comamnd is already a full path and exists, return if
  if fileExists(cmd):
    return some(cmd)

  # search in normal paths.
  let cpath = findExe(cmd)
  if fileExists(cpath):
    return some(cpath)

  # Now search in hints.
  for hint in hints:
    # debug(fmt">>> Walking in {hint}")
    for d in walkDirRec(hint, yieldFilter={pcDir}):
      let f = d / cmd
      if f.fileExists:
        # info(fmt">> Found {f}")
        return some(f)
  return none(string)


proc ensureCommand*(cmd: string, pkgname: string = "", globs: openArray[
    string] = []): Option[string] =
  ##
  ## Ensure that a command exists. If found, return the path else install the given package
  ## `pkgame`
  ##
  if fileExists(cmd):
    return some(cmd)

  let cpath = findCommand(cmd, globs)
  if cpath.isSome and fileExists(cpath.get):
    return cpath

  var toinstall = cmd
  if pkgname.len > 0:
    toinstall = pkgname
  warn(fmt">>> {cmd} could not be found. Trying installing {toinstall}.")
  none(string)


when isMainModule and detectOs(Windows):
  var c = ensureCommand("choco")
  doAssert c.isSome and fileExists(c.get)
  echo "\n\n====="
  c = ensureCommand("msbuild.exe", "visualstudio2019community"
    , globs = ["C:/Program Files (x86)/Microsoft Visual Studio/**/msbuild.exe"])
  doAssert c.isSome and fileExists(c.get)
