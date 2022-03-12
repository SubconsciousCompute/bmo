# Install module.

import std/distros
import std/strformat

import std/os
import std/osproc
import std/options

import fusion/matching

import bmopkg/command

proc install_cmd*(pkgname: string): string =
  let (cmd, issudo) = foreignDepInstallCmd(pkgname)
  if issudo and (not isAdmin()):
    return fmt"sudo {cmd}"
  return cmd


proc ensure(cmd: string, pkgname: string) : string =
  ## Ensure that a command exists.
  if Some(@val) ?= find_command(cmd):
    return cmd
