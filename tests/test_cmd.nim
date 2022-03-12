# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import std/os, options, strformat, distros
import std/logging

import bmopkg/command

var logger = newConsoleLogger()
addHandler(logger)

# Find cmake.
let cmake = findCommand("cmake")
assert cmake.isSome

assert fileExists(cmake.get), fmt"{cmake=} is not found"

if defined(windows):
  echo ">>> Testing on Windows"
  let choco = ensureCommand("choco.exe")
  assert choco.isSome
  assert fileExists(choco.get), fmt"Could not find {choco=}"
