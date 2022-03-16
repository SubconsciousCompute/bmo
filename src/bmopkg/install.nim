##
## Install module.
##

import std/[os, logging, distros, strutils, sequtils, strformat]

import fusion/matching

import ./common

type
  SystemPkgMgr = tuple[os: string, name: string]
  ## Abstractions of commands (for non-interactive use)
  PkgCommand* = ref object
    install: string        # install a package
    uninstall: string      # uninstall a package
    upgrade_all: string    # upgrade all installed packages
    update: string         # update a package
    list_installed: string # list installed  packages.
    search: string         # search a package.
    sudo: bool
  ## Information related to a package.
  PkgInfo* = object 
    name*: string
    version*: string

proc toTxt*(p: PkgInfo): string =
  return fmt"{p.name} {p.version}"

## Const resources.
const ChocoInstallScript: string = staticRead("../../data/install_choco.ps1")

proc sysPkgManager(): SystemPkgMgr =
  ##
  ## Return OS and package manager command.
  ##
  when defined(windows):
    result = ("windows", "choco")
  elif defined(bsd):
    result = ("bsd", "ports")
  elif defined(linux):
    result[0] = "linux"
    if detectOs(Ubuntu) or detectOs(Elementary) or detectOs(Debian) or
        detectOs(KNOPPIX) or detectOs(SteamOS):
      result[1] = "apt"
    elif detectOs(Gentoo):
      result[1] = "emerge"
    elif detectOs(Fedora):
      result[1] = "dnf"
    elif detectOs(RedHat):
      result[1] = "rpm"
    elif detectOs(OpenSUSE):
      result[1] = "zypper"
    elif detectOs(Slackware):
      result[1] = "installpkg"
    elif detectOs(OpenMandriva):
      result[1] = "urpmi"
    elif detectOs(ZenWalk):
      result[1] = "netpkg"
    elif detectOs(NixOS):
      result[1] = "nix-env"
    elif detectOs(ArchLinux) or detectOs(Manjaro) or detectOs(Artix):
      debug("On ArchLinux or its derivative.")
      result[1] = "pacman"
    # Put non-Linuxy stuff here.
    elif detectOs(Solaris) or detectOs(FreeBSD):
      result[1] = "pkg"
    elif detectOs(OpenBSD):
      result[1] = "pkg_add"
    elif detectOs(PCLinuxOS):
      result[1] = "rpm"
    elif detectOs(Void):
      result[1] = "xbps-install"
    else:
      result = ("", "")
  elif defined(haiku):
    result[1] = "pkgman"
  else:
    result[1] = "brew"

proc getPkgMgrName(name: string = ""): string =
  # helper function.
  if name.len == 0:
    return sysPkgManager().name
  return name

proc pkgManagerCommands*(manager: string = ""): PkgCommand =
  ##
  ## Abstraction of package manager command for non-interactive use. If package manager name is not
  ## given, it is computed.
  ##
  let name = getPkgMgrName(manager)
  doAssert name.len > 0, "Could not determine package manager"

  # initialize PkgCommand. Wait for Nim-2 then we can initialize fields in declaration itself.
  var cmds = new(PkgCommand)
  cmds.sudo = true

  case name:
    of "choco":
      cmds.install = fmt"{name} install -y <pkg>"
      cmds.uninstall = fmt"{name} uninstall -y --force <pkg>"
      cmds.list_installed = fmt"{name} list --local-only --no-color"
      cmds.sudo = false
    of "ports":
      cmds.install = fmt"{name} install <pkg>"
    of "apt":
      cmds.install = fmt"{name} install -y <pkg>"
    of "emerge":
      cmds.install = fmt"{name} install -y <pkg>"
    of "dnf":
      cmds.install = fmt"{name} install -y <pkg>"
      cmds.uninstall = fmt"{name} remove -y <pkg>"
    of "rpm":
      cmds.install = fmt"{name} install --force <pkg>"
    of "zypper":
      cmds.install = fmt"{name} install --non-interactive <pkg>"
      cmds.uninstall = fmt"{name} remove --non-interactive <pkg>"
    of "nix-env":
      cmds.install = fmt"{name} -i <pkg>"
      cmds.sudo = false
    of "pkg":
      cmds.install = fmt"{name} install -y <pkg>"
      cmds.sudo = true
    of "pkg_add":
      cmds.install = fmt"{name} install -I <pkg>"
    of "pacman":
      cmds.install = fmt"{name} -S --noconfirm <pkg>"
      cmds.uninstall = fmt"{name} -Rsc --noconfirm <pkg>"
    of "brew":
      cmds.install = fmt"{name} install -y <pkg>"
      cmds.install = fmt"{name} uninstall -y <pkg>"
      cmds.sudo = false
    else:
      warn("Not a supported package manger {pkgmgr}")
      cmds.sudo = false
  return cmds

#
# Convert to executable commands.
#
proc getCommand(task: string, pkgname: string = "",
    manager: string = ""): Option[string] =
  ##
  ## Get command for given task such as 'install', 'uninstall', 'list_installed' etc.
  ##
  let pkgmgr = getPkgMgrName(manager)
  let cmds = pkgManagerCommands(pkgmgr)

  var cmd = ""
  if task == "install":
    cmd = cmds.install
  elif task == "uninstall":
    cmd = cmds.uninstall
  elif task == "list_installed":
    cmd = cmds.list_installed
  else:
    warn(fmt"Unsupported type of task '{task}' passed to this function.")
    return none(string)

  if cmd.len == 0:
    warn(fmt"Unsupported type of task '{task}'.")
    return none(string)

  # replace placeholder <pkg> with pkgname.
  cmd = replace(cmd, "<pkg>", pkgname)
  if cmds.sudo:
    cmd = "sudo " & cmd
  return some(cmd)

proc listInstalledPkgs*(): seq[PkgInfo] =
  ##
  ## List installed packages.
  ##
  let pkgmgr = getPkgMgrName()
  let cmd = getCommand("list_installed", manager = pkgmgr)
  var res: string = ""
  if not cmd.is_some:
    warn("Could not determine the list_installed command");
    return @[]

  res = execute(cmd.get)
  var pkgs: seq[PkgInfo] = @[]
  for x in res.splitLines:
    let fs = x.strip.splitWhiteSpace
    if pkgmgr == "choco":
      if fs.len == 2:
        pkgs.add(PkgInfo(name: fs[0], version: fs[1]))
  return pkgs


proc isInstalled*(pkgname: string) : bool=
  ##
  ## Checks if a package is already installed.
  ##
  let ls = listInstalledPkgs()
  if not ls.anyIt(it.name.toLower == pkgname.toLower):
    info(fmt"{pkgname} is not installed on this system.")
    return false
  return true


#
# Other tasks.
#
proc installPackage*(pkgname: string, force: bool = false): bool =
  ##
  ## Install a package.
  ## User should make sure that installation is required or not.
  ##
  let cmd = getCommand("install", pkgname)
  doAssert cmd.is_some, "Could not determine install command."

  # check if the package is already installed.
  if not force and isInstalled(pkgname):
    info(fmt"{pkgname} is already installed. Use `force=true` to force reinstall")
    return true

  # FIXME: Should I use execCmdEx here?
  # execute the command.
  discard execute(cmd.get)
  return true


proc ensureCommand*(cmd: string, package: string = ""): Option[string] =
  ##
  ## Ensure that a pkgname exists. If not try installing it.
  ##
  var path = findExe(cmd)
  if path.fileExists:
    return some(path)

  var pkgname = package
  if pkgname.len == 0:
    pkgname = cmd

  doAssert installPackage(pkgname), fmt"Installation of {pkgname} failed"
  path = findExe(cmd)
  if path.fileExists:
    return some(path)
  none(string)

proc ensurePackage*(pkgname: string): bool=
  ## 
  ## Make sure that a package exists on system. Note that this is different than `ensureCommand`
  ## function. Unlike this function, `ensureCommand` will not install a package is a given `cmd` is
  ## found. For example, `ensureCommand('cmake')` may not install `cmake` using choco if `cmake` is
  ## found in PATH installed by some other method.
  ##
  let ls = listInstalledPkgs()
  if ls.anyIt(it.name.toLower == pkgname.toLower):
    return true
  doAssert installPackage(pkgname), fmt"Installation of {pkgname} failed."
  return true


proc removePackage*(pkgname: string): bool =
  ##
  ## Remove a program. Return 'true' on success, `false` on failure. If the package was not
  ## installed then returns `true`.
  ##
  let cmd = getCommand("uninstall", pkgname)
  doAssert cmd.isSome, "Could not determine uninstall command"
  discard execute(cmd.get)
  return true



proc ensureChoco*(): Option[string] =
  ##
  ## Make sure that choco is available.
  ## It can't be handled by ensureCommand because choco requires executing its own script.
  ##
  if not defined(windows):
    warn("Choco is only works on Windows")
    return none(string)

  var choco = findExe("choco")
  if choco.fileExists:
    info(fmt"Choco is already installed {choco}")
    return some(choco)

  discard execute(fmt"powershell.exe {ChocoInstallScript}")
  choco = findExe("choco")
  if not choco.fileExists:
    warn("Unable to find choco after installation.")
    return none(string)
  return some(choco)

#
# Module specific tests
#
when isMainModule:
  echo "\n\n>> MainModule: Running tests"
  let x = getCommand("install", "cmake")
  doAssert x.is_some, fmt"Could not determine install command {x}"
  echo fmt"Install command on this platform is '{x.get}'"

  doAssert ensurePackage("cmake")
  doAssert isInstalled("cmake"), "Failed to find cmake after installation"

  if defined windows:
    echo "Test: Ensure choco"
    doAssert ensureChoco().isSome, "Could not install choco"
