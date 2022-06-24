__author__ = "Dilawar Singh"
__email__ = "dilawar@subcom.tech"

import subprocess
import platform
import tempfile
import shutil

from pathlib import Path

from loguru import logger

import subcom.common
import subcom.command


def _get_manager_opts() -> list[str]:
    if subcom.common.is_windows():
        _choco = subcom.command.find("choco")
        assert _choco is not None and _choco.exists()
        return ["-m", "choco"]
    return []


def install_pkg(dep: str, extra: list[str] = []):
    """Install a pkg"""
    opts = _get_manager_opts()
    subprocess.check_output(["mpm"] + opts + extra + ["install", dep])


def ensure_choco() -> Path:
    """Ensure that choco.exe exists on system"""
    if not subcom.common.is_windows():
        raise RuntimeError(
            f"choco.exe is available only on Windows. This system is {platform.system()}"
        )

    if choco := shutil.which("choco.exe"):
        logger.info(f"choco.exe is already installed: {choco}")
        return Path(choco)

    with tempfile.TemporaryFile(prefix="choco.ps1") as tmp:
        ps_str = b"""Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"""
        tmp.write(ps_str)
        subprocess.check_output(["powershell.exe", tmp.name])

    chocopath = subcom.command.find("choco.exe")
    if chocopath is None:
        logger.warning("choco.exe is not found")
        raise RuntimeError("could not locate choco.exe")

    return Path(chocopath)


def ensure_pkg(pkgname: str, binpath: Path) -> Path:
    """Ensure that a given package name (with associated file) is available on the system"""


def ensure_visual_studio(
    pkg: str = "visualstudio2019community", trial_left: int = 1
) -> Path:
    """Ensure that Visual Studio 2019 is installed and returns the path to msbuid.exe"""
    msbuild = subcom.command.find(
        "msbuild.exe",
        hints=["C:/Program Files (x86)/Microsoft Visual Studio"],
        recursive=True,
    )

    if msbuild is None and trial_left > 0:
        logger.info(f"Trying to install {pkg} {trial_left=}")
        install_pkg(pkg)
        ensure_visual_studio(trial_left=trial_left - 1)

    assert msbuild is not None and msbuild.exists()
    return Path(msbuild)


def ensure_cmake() -> Path:
    """Ensure that cmake is installed"""
    _cmake = subcom.command.find("cmake")
    if _cmake is not None and _cmake.exists():
        return Path(_cmake)

    extra = []
    if subcom.common.is_windows():
        extra = ["--installargs", "ADD_CMAKE_TO_PATH"]
    install_pkg("cmake", extra=extra)

    if (_cmake := subcom.command.find("cmake")) is None:
        raise RuntimeError("cmake could not be found")
    return Path(_cmake)
