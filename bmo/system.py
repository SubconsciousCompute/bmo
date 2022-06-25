"""
Command module.
"""

__author__ = "Dilawar Singh"
__email__ = "dilawar@subcom.tech"

import shutil
import itertools
import typing as T
import logging

from pathlib import Path


def find(
    cmd: str,
    *,
    hints: T.List[T.Union[str, Path]] = [],
    subdirs: T.List[str] = [],
    recursive: bool = False,
) -> T.Optional[Path]:
    """Find an executable.

    Parameters
    ----------
        cmd : name of the command. On windows, we also search for `foo.exe` if `foo` is given.
        hints : List of directories in addition to `PATH` where we search for executable.
        subdirs : List of subdirs. Each subdir is suffixed to every hints.
        recursive : If recursive is set to `True`, search as deep as possible to find the executable
        file.

    Returns
    -------
    Path of the executable if found, `None` otherwise.
    """

    # On windows, append .exe to cmd.
    winname = f"{cmd}.exe" if not cmd.endswith(".exe") else cmd

    # If the full path is given, nothing to search. Return it.
    for cmd in (cmd, winname):
        p = Path(cmd)
        if p.exists():
            return p

    # Search in PATH using shutils.
    c = shutil.which(cmd)
    if c is not None:
        return Path(c)

    # search in hints and subdirs. Try to mimic cmake's find_command macro.
    subdirs.append(".")
    for hint, subdir in itertools.product(hints, subdirs):
        e = Path(hint) / subdir
        logging.debug(f" Searching for {cmd} in {str(e)}")
        if not e.exists():
            logging.warning(f" Location '{str(e)}' doesn't exist. Ignoring...")
            continue

        if e.is_file() and (e.name == cmd or e.name == winname):
            return e

        if recursive and e.is_dir():
            fs = T.List(e.glob(f"**/{cmd}")) + T.List(e.glob(f"**/{winname}"))
            if len(fs) > 1:
                logging.warning(
                    "Multiple binaries found with same name: \n\t"
                    + "\n\t".join(map(str, fs))
                    + ".\nReturning the first one."
                )
            return fs[0] if len(fs) > 1 else None
    return None


# alias
find_executable = find


def cmake() -> Path:
    """get cmake path"""
    cmake = find("cmake")
    if cmake is None or not cmake.is_file():
        logging.warning("cmake.exe is not found")
        raise Exception("cmake not found")
    return cmake


def msbuild() -> Path:
    """get cmake path"""
    msbuild = find_executable(
        "msbuild.exe",
        hints=["C:/Program Files (x86)/Microsoft Visual Studio"],
        recursive=True,
    )
    assert msbuild is not None and msbuild.exists(), f"Could not find msbuild.exe"
    return Path(msbuild)
