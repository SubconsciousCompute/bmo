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
  # initialize hint with default values.
  var paths : seq[string] = @hints
  if defined(windows):
    paths = paths & @["C:/tools/", "C:/Program Files (x86)", "C:/Program Files"]
  else:
    paths = paths & @["/opt", "~/.local/bin"]

  var sdirs = @suffixes
  sdirs.add(".")

  for (a, b) in product(paths, sdirs):
    let p = expandTilde(a / b / cmd)
    if fileExists(p):
      return some(p)
    if recursive:
      var pat = fmt"{a}/**/{cmd}"
      if b != "." and b.len > 2:
        pat = fmt"{a}/{b}/**/{cmd}"
      for p in walkGlob(pat):
        info(fmt">>> {p}")
        if fileExists(p):
          return some(p)
  warn(fmt">> Could not find executable for command {cmd}")
  none(string)


proc ensureCommand*(cmd: string, pkgname: string = "",
    hints: openArray[string] = [], suffixes: openArray[string] = []): Option[string] =
  ## Ensure that a command exists.
  if fileExists(cmd):
    return some(cmd)

  let cpath = findCommand(cmd, hints = hints, suffixes = suffixes, recursive = true)
  if cpath.isSome and fileExists(cpath.get):
    return cpath

  var toinstall = cmd
  if pkgname.len > 0:
    toinstall = cmd
  warn(fmt">>> {cmd} could not be found. Trying installing {toinstall}.")
  none(string)


when isMainModule and detectOs(Windows):
  var c = ensureCommand("choco")
  doAssert c.isSome and fileExists(c.get)
  echo "\n\n====="
  c = ensureCommand("msbuild.exe", "visualstudio2019community")
  doAssert c.isSome and fileExists(c.get)
