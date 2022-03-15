# Install module.

import std/[os, logging, distros, strformat]

import fusion/matching

import ./common

type
  SystemPkgMgr = tuple[os: string, name: string]
  ## Abstractions of commands (for non-interactive use)
  PkgCommand = ref object
    install: string        # install a package
    uninstall: string      # uninstall a package
    upgrade_all: string    # upgrade all installed packages
    update: string         # update a package
    list_installed: string # list installed  packages.
    search: string         # search a package.
    sudo: bool

## Const resources.
const ChocoInstallScript: string = staticRead("../data/install_choco.ps1")

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
      info("On ArchLinux or its derivative.")
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

proc pkgManagerCommands(manager: string = ""): PkgCommand =
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
      cmds.install = fmt"{name} install -y"
      cmds.uninstall = fmt"{name} uninstall -y"
      cmds.sudo = false
    of "ports":
      cmds.install = fmt"{name} install"
    of "apt":
      cmds.install = fmt"{name} install -y"
    of "emerge":
      cmds.install = fmt"{name} install -y"
    of "dnf":
      cmds.install = fmt"{name} install -y"
      cmds.uninstall = fmt"{name} remove -y"
    of "rpm":
      cmds.install = fmt"{name} install --force"
    of "zypper":
      cmds.install = fmt"{name} install --non-interactive"
      cmds.uninstall = fmt"{name} remove --non-interactive"
    of "nix-env":
      cmds.install = fmt"{name} -i"
      cmds.sudo = false
    of "pkg":
      cmds.install = fmt"{name} install -y"
    of "pkg_add":
      cmds.install = fmt"{name} install -I"
    of "pacman":
      cmds.install = fmt"{name} -S --noconfirm"
      cmds.uninstall = fmt"{name} -Rsc --noconfirm"
    of "brew":
      cmds.install = fmt"{name} install -y"
      cmds.install = fmt"{name} uninstall -y"
      cmds.sudo = false
    else:
      warn("Not a supported package manger {pkgmgr}")
      cmds.install = "<NA>"
      cmds.sudo = false
  return cmds



#
# Convert to executable commands.
#
proc getCommand(task: cstring, pkgname: cstring,
    manager: string = ""): Option[string] =
  ##
  ## Get command for given task such as 'install', 'uninstall', 'list' etc.
  ##
  let pkgmgr = getPkgMgrName(manager)
  let cmds = pkgManagerCommands(pkgmgr)

  var cmd = ""
  if task == "install":
    cmd = cmds.install
  elif task == "uninstall":
    cmd = cmds.uninstall
  else:
    warn(fmt"Unsupported type of task '{task}' passed to this function.")
    return none(string)

  if cmd.len == 0:
    warn(fmt"Unsupported type of task '{task}'.")
    return none(string)

  cmd = fmt"{cmd} {pkgname}"
  if cmds.sudo:
    cmd = "sudo " & cmd
  return some(cmd)


#
# Other tasks.
#
proc installPackage*(pkgname: string, force_yes: bool = true): bool =
  ##
  ## Install a package.
  ## User should make sure that installation is required or not.
  ##
  let cmd = getCommand("install", pkgname)
  doAssert cmd.is_some, "Could not determine install command."

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

  echo "Test: Ensure cmake"
  doAssert removePackage("cmake")
  doAssert ensureCommand("cmake").isSome

  if defined windows:
    echo "Test: Ensure choco"
    doAssert ensureChoco().isSome, "Could not install choco"
