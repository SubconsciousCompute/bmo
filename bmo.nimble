import std/strformat 

# Package

version       = "0.1.0"
author        = "Dilawar Singh <dilawar@subcom.tech>"
description   = "BMO does all automation at SubCom"
license       = "AGPL-3.0-only"
backend       = "c"

srcDir        = "src"

installExt    = @["nim"]
bin           = @["bmo"]

# Dependencies
requires "nim >= 1.6"
requires "fusion"
requires "cligen"


task html, "generate HTML docs":

  echo "generating docs in htmldocs"
  let outdir = "htmldocs"
  selfExec fmt"doc --project --index:on --outdir:{outdir} src/bmo.nim"
  mvFile outdir & "/bmo.html", outdir & "/index.html"
