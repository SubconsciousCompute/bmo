## Command module.
##
## Author: Dilawar Singh <dilawar@subcom.tech>
## See the output of `git blame` as well.

import std/[os, strformat, distros, sequtils, options, logging]
import bmopkg/install

import glob
import itertools

var logger = newConsoleLogger()
addHandler(logger)

proc findCommand*(cmd: string, hints: openArray[string] = @[],
    suffixes: openarray[string] = @[], recursive: bool = true): Option[string] =
  ## Find a given command.
  ##
  ## If not found in PATH, try finding it in given hints and subdirs. 
  ## Tries to mimic CMake's `find_program` macro https://cmake.org/cmake/help/latest/command/find_program.html 
  ##
  ## Return some(path) on success. None otherwise.

  # if the given comamnd is already a full path and exists, return if
  if fileExists(cmd):
    return some(cmd)

  let cpath = findExe(cmd)
  if cpath.len >= cmd.len:
    debug(fmt"Found {cmd} at {cpath}")
    assert fileExists(cpath)
    return some(cpath)

  # Now search in hints.
  var sdirs = @suffixes
  sdirs.add(".")
  for (a, b) in product(hints, suffixes):
    info(fmt"Searching in {a}/{b}")
    if not recursive:
      let p = a / b / cmd
      if p.fileExists:
        return some(p)
  warn(fmt"> Could not find executable for command {cmd}")
  none(string)

proc ensureCommand*(cmd: string, pkgname: Option[string] = none(string),
    hints: openArray[string]=[], subdirs: openArray[string]=[]): Option[string] =
  ## Ensure that a command exists.
  if fileExists(cmd):
    return some(cmd)

  # initialize hint with default values.
  var paths = @["/opt", "~/.local/bin"]
  if defined(windows):
    paths = @["C:/tools/", "]

  paths &= hints
  let cpath = findCommand(cmd, hints = paths, subdirs=subdirs, recursive=true)
  if cpath.isSome and fileExists(cpath.get):
    return cpath

  warn(fmt"{cmd} could not be found. Trying installing {pkgname}.")
  none(string)


#
when isMainModule:
  var c = ensureCommand("choco")
  doAssert(c.isSome and fileExists(c.get))

  c = ensureCommand("msbuild.exe")
  doAssert(c.isSome and fileExists(c.get))
