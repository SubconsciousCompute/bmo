# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import std/os, options, strformat
import std/logging

import bmopkg/command

var logger = newConsoleLogger()
addHandler(logger)

let cmake = find_command("cmake")
assert cmake.isSome

assert fileExists(cmake.get), fmt"{cmake=} is not found"
