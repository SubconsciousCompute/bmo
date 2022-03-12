# Install module.

import std/distros
import std/strformat

import std/[os, logging, distros]

import fusion/matching

var logger = newConsoleLogger()
addHandler(logger)

proc installCommand(foreignPackageName: string, noninteractive: bool = true): string =
  ## Returns the distro's native command to install `foreignPackageName`
  ## and whether it requires root/admin rights.
  ## If `noninteractive is set to `true`, then command is modified to assume `yes` to all user
  ## questions.
  let p = foreignPackageName

  var res = ("", false)
  var ni = ""

  when defined(windows):
    if noninteractive:
      ni = "--yes "
    res = ("choco install " & ni & p, false)
  elif defined(bsd):
    if noninteractive:
      putEnv("BATCH", "yes")
    res = ("ports install " & p, true)
  elif defined(linux):
    if detectOs(Ubuntu) or detectOs(Elementary) or detectOs(Debian) or
        detectOs(KNOPPIX) or detectOs(SteamOS):
      if noninteractive:
        ni = "-y "
      res = ("apt-get install " & ni & p, true)
    elif detectOs(Gentoo):
      if noninteractive:
        ni = "-y "
      res = ("emerge install " & ni & p, true)
    elif detectOs(Fedora):
      if noninteractive:
        ni = "-y "
      res = ("yum install " & ni & p, true)
    elif detectOs(RedHat):
      if noninteractive:
        ni = "--force "
      res = ("rpm install " & ni & p, true)
    elif detectOs(OpenSUSE):
      if noninteractive:
        ni = "--non-interactive "
      res = ("zypper install " & ni & p, true)
    elif detectOs(Slackware):
      if noninteractive:
        warn("Not sure how to handle noninteractive mode")
      res = ("installpkg " & ni & p, true)
    elif detectOs(OpenMandriva):
      if noninteractive:
        warn("Not sure how to handle noninteractive mode")
      res = ("urpmi " & ni & p, true)
    elif detectOs(ZenWalk):
      if noninteractive:
        warn("Not sure how to handle noninteractive mode")
      res = ("netpkg install " & ni & p, true)
    elif detectOs(NixOS):
      if noninteractive:
        warn("Not sure how to handle noninteractive mode")
      res = ("nix-env -i " & ni & p, false)
    elif detectOs(Solaris) or detectOs(FreeBSD):
      if noninteractive:
        ni = "-y "
      res = ("pkg install " & ni & p, true)
    elif detectOs(OpenBSD):
      if noninteractive:
        ni = "-I "
      res = ("pkg_add " & ni & p, true)
    elif detectOs(PCLinuxOS):
      if noninteractive:
        ni = "--force "
      res = ("rpm -ivh " & ni & p, true)
    elif detectOs(ArchLinux) or detectOs(Manjaro) or detectOs(Artix):
      if noninteractive:
        ni = "--noconfirm "
      res = ("pacman -S " & ni & p, true)
    elif detectOs(Void):
      if noninteractive:
        ni = "--yes "
      res = ("xbps-install " & ni & p, true)
    else:
      res = ("<your package manager here> install " & p, true)
  elif defined(haiku):
    if noninteractive:
      warn("Not sure how to handle noninteractive mode")
    res = ("pkgman install " & ni & p, true)
  else:
    if noninteractive:
      ni = "--yes "
    res = ("brew install " & ni & p, false)

  # finally return the command.
  result = res[0]
  if res[1]:
    result = "sudo " & result


proc install(pkgname: string, force_yes: bool = true): bool =
  ## Install a package of given pkgname.
  ## User should make sure that installation is required or not.
  let cmd = installCommand(pkgname)
  if cmd.len < 2:
    warn(fmt"Could not determine the install command {cmd}")
    return false
  # FIXME: Should I use execCmdEx here?
  # execute the command.
  discard execShellCmd(cmd)
  return true


when isMainModule:
  echo "Running tests"
  let x = installCommand("cmake")
  doAssert x.len > 0, fmt"Could not determine install command {x}"
  echo fmt"Install command on this platform is '{x}'"
  doAssert install("cmake"), "installation successfull"
