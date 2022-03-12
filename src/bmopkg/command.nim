## Command module.
##
## Author: Dilawar Singh <dilawar@subcom.tech>
## See the output of `git blame` as well.

import std/[os, strformat, distros, sequtils, options, logging]

import glob
import itertools

import ./install

var logger = newConsoleLogger()
addHandler(logger)

proc findCommand*(cmd: string, globList: openArray[string] = @[]): Option[string] =
  ##
  ## Find a given command.
  ##
  ## If not found in PATH, try finding it using list of globs patterns.
  ## See https://glob.bolingen.me/latest/glob.html for supported glob pattern.
  ##
  ## Return some(path) on success. None otherwise.
  ##
  # if the given comamnd is already a full path and exists, return if
  if fileExists(cmd):
    return some(cmd)

  let cpath = findExe(cmd)
  if cpath.len >= cmd.len:
    debug(fmt"Found {cmd} at {cpath}")
    assert fileExists(cpath)
    return some(cpath)

  # Now search in hints.
  for pat in globList:
    let (rootdir, magic) = pat.splitPattern
    debug(fmt">> Searching using {magic=} in {rootdir=}.")
    for p in walkGlob(magic, root=rootdir):
      if fileExists(p):
        return some(p)
  warn(fmt"> Could not find executable for command {cmd}")
  none(string)


proc ensureCommand*(cmd: string, pkgname: string = "", globs: openArray[string] = []): Option[string] =
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
    , globs=["C:/Program Files (x86)/Microsoft Visual Studio/**/msbuild.exe"])
  doAssert c.isSome and fileExists(c.get)
