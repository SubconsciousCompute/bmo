## SubCom tools.
## Author: Dilawar Singh <dilawar@subcom.tech>

import std/tables
import std/[strformat, sequtils]

import ./install

const Groups = {
  "minimal": @["choco", "nim", "cmake", "visualstudio2019community"]
  }.toTable

proc installGroupLinux(group: string): bool =
  discard

proc installGroupWindows(group: string): bool =
  ## Install a group on Windows.
  if not Groups.contains(group):
    warn(fmt"{group} does not exists. Available groups are: {Groups.keys.toSeq}")

proc installGroup*(group: string): bool =
  ## Install a given group.
  if defined(Windows):
    return installGroupWindows(group)

  if defined(Linux):
    return installGroupLinux(group)

  warn("Group {group} is not supported on this platform.")
  return false


when isMainModule:
  echo "> isMainModule is true. Running inbuilt tests."
  echo listInstalled()
