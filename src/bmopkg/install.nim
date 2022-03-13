# Install module.

import std/[os, logging, distros, strformat]

import fusion/matching

import ./common

type 
  SystemPkgMgr = tuple[os: string, name: string]
  PkgCommand = tuple[install: string, sudo: bool]

## Const resources.
const ChocoInstallScript : string = staticRead("../data/install_choco.ps1")

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
    elif detectOs(Solaris) or detectOs(FreeBSD):
      result[1] = "pkg"
    elif detectOs(OpenBSD):
      result[1] = "pkg_add"
    elif detectOs(PCLinuxOS):
      result[1] = "rpm"
    elif detectOs(ArchLinux) or detectOs(Manjaro) or detectOs(Artix):
      result[1] = "pacman"
    elif detectOs(Void):
      result[1] = "xbps-install"
    else:
      result = ""
  elif defined(haiku):
    result[1] = "pkgman"
  else:
    result[1] = "brew"


proc pkgManagerCommands(name: string): PkgCommand =
  ##
  ## Abstraction of package manager command for non-interactive use.
  ##
  result = case name:
    of "choco":
      (install: fmt"{name} install -y", sudo: false)
    of "ports":
      (install: fmt"{name} install", sudo: true)
    of "apt":
      (install: fmt"{name} install -y", sudo: true)
    of "gentoo":
      (install: fmt"{name} install -y", sudo: true)
    of "dnf":
      (install: fmt"{name} install -y", sudo: true)
    of "rpm":
      (install: fmt"{name} install --force", sudo: true)
    of "zypper":
      (install: fmt"{name} install --non-interactive", sudo: true)
    of "nix-env":
      (install: fmt"{name} -i", sudo: false)
    of "pkg":
      (install: fmt"{name} install -y", sudo: true)
    of "pkg_add":
      (install: fmt"{name} install -I", sudo: true)
    of "pacman":
      (install: fmt"{name} -S --noconfirm", sudo: true)
    of "brew":
      (install: fmt"{name} install -y", sudo: false)
    else:
      warn("Not a supported package manger {pkgmgr}")
      (install: "<NA>", sudo: false)


proc installCommand*(pkgname: string, manager: string = ""): string =
  ##
  ## Install command for given.
  ##
  var pkgmgr : string = manager
  if pkgmgr.len == 0:
    # No package manager is given, using system pkg manager.
    pkgmgr = sysPkgManager().name

  let cmds = pkgManagerCommands(pkgmgr)
  if cmds.sudo:
    result = fmt"sudo {cmds.install} {pkgname}"
  else:
    result = fmt"{cmds.install} {pkgname}"


proc installPackage*(pkgname: string, force_yes: bool = true): bool =
  ##
  ## Install a package.
  ## User should make sure that installation is required or not.
  ##
  let cmd = installCommand(pkgname)
  if cmd.len < 2:
    warn(fmt"Could not determine the install command {cmd}")
    return false
  # FIXME: Should I use execCmdEx here?
  # execute the command.
  discard execute(cmd)
  return true

proc ensure(pkgname: string, cmd: string): string=
  ## Ensure that a pkgname exists. If not try installing it.
  var path = findExe(cmd)
  if path.fileExists:
    return path
  discard installPackage(pkgname)
  path = findExe(cmd)
  doAssert path.fileExists, "Could not find {cmd} after installing {pkgname}"
  return path

proc ensureChoco(): bool=
  ## Make sure that choco is available.
  if not defined(windows):
    warn("Choco is only works on Windows")
    return false

  var choco = findExe("choco")
  if choco.fileExists:
    info(fmt"Choco is already installed {choco}")
    return true

  discard execute(fmt"powershell.exe {ChocoInstallScript}")
  choco = findExe("choco")
  if not choco.fileExists:
    warn("Unable to find choco after installation.")
    return false
  return true

when isMainModule:
  echo "MainModule: Running tests"
  let x = installCommand("cmake")
  doAssert x.len > 0, fmt"Could not determine install command {x}"
  echo fmt"Install command on this platform is '{x}'"

  echo "Ensure cmake"
  doAssert installPackage("cmake"), "installation was not successfull"
  let cmake = ensure("cmake", "cmake")
  echo fmt"> Found cmake {cmake}"
  doAssert fileExists(cmake), fmt"{cmake} is not found."

  echo "Ensure choco"
  doAssert ensureChoco(), "Could not install choco"
