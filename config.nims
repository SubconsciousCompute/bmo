import std/distros

switch("backend", "cpp")
switch("threads", "on")

if defined(windows):
  echo ">> On windows. Looking for MinGW compiler"
  switch("define", "mingw")
  switch("putenv", "CXX=c:/tools/msys64/mingw64/bin/g++.exe")
  switch("cc", "env")
  
