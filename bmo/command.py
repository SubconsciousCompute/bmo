"""
Command module.
"""

__author__ = "Dilawar Singh"
__email__ = "dilawar@subcom.tech"

import subprocess
import shutil
import itertools
import functools
import typing as T

from pathlib import Path

from loguru import logger


def find(
    cmd: str,
    *,
    hints: list[T.Union[str, Path]] = [],
    subdirs: list[str] = [],
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
        if p := Path(cmd):
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
        logger.debug(f" Searching for {cmd} in {str(e)}")
        if not e.exists():
            logger.warning(f" Location '{str(e)}' doesn't exist. Ignoring...")
            continue

        if e.is_file() and (e.name == cmd or e.name == winname):
            return e

        if recursive and e.is_dir():
            if fs := list(e.glob(f"**/{cmd}")) + list(e.glob(f"**/{winname}")):
                if fs:
                    if len(fs) > 1:
                        logger.warning(
                            "Multiple binaries found with same name: \n\t"
                            + "\n\t".join(map(str, fs))
                            + ".\nReturning the first one."
                        )
                    return fs[0]
    return None


# alias
find_executable = find


def cmake() -> Path:
    """get cmake path"""
    cmake = find("cmake")
    if cmake is None or not cmake.is_file():
        logger.warning("cmake.exe is not found")
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
