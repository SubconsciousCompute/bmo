## Command.

import std/[os, strformat, sequtils, options, logging]

import itertools

var logger = newConsoleLogger()
addHandler(logger)

proc findCommand*(cmd: string, hints: openArray[string] = @[],
    subdirs: openarray[string] = @[], recursive: bool = true): Option[string] =
  ## Find a given command.
  ##
  ## If not found in PATH, find it in givens hints and subdirs (mimics CMake's find_command
  ## function.
  ##
  ## Return some(path) on success. None otherwise.

  # if the given comamnd is already a full path and exists, return if
  if fileExists(cmd):
    return some(cmd)

  debug(fmt"Searching for {cmd}")
  var cmd = findExe(cmd)
  if fileExists(cmd):
    return some(cmd)

  # Now search in hints.
  var sdirs = @subdirs
  sdirs.add(".")
  for (a, b) in product(hints, sdirs):
    info(fmt" {a}/{b}")

  debug(fmt"> Could not find executable for command {cmd}")
  none(string)
