# network module
__author__ = "Dilawar Singh"

__email__ = "dilawar@subcom.tech"

import re
import datetime
import requests
import subprocess

import dateutil.parser
import dateutil.utils

from urllib.parse import urlparse

from loguru import logger

import typer

app = typer.Typer()

import bmo.common


def parse_x509_date(datestr: str):
    return dateutil.parser.parse(datestr)


@app.command()
def speedtest():
    import speedtest as _st

    logger.info("Running speedtest")
    s = _st.Speedtest()
    s.get_servers([])
    s.get_best_server()
    s.download(threads=None)
    s.upload(threads=None)
    try:
        s.results.share()
    except Exception as e:
        pass
    res = s.results.dict()
    res["download"] = res["download"] / 1024 / 1024
    res["upload"] = res["download"] / 1024 / 1024
    print(res)


@app.command()
def check_ssl(server: str, port: int = 443):
    """Check SSL certificate of a given url."""
    if not server.startswith("https"):
        server = f"https://{server}"
    logger.info(f"Checking certificate for {server}")
    openssl = bmo.common.find_program("openssl")
    assert openssl is not None
    domain = urlparse(server).netloc
    # See https://docs.python.org/3/library/subprocess.html#replacing-shell-pipeline
    pssl = subprocess.Popen(
        f"{openssl} s_client -servername {server} -connect {domain}:{port}".split(),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    pparse = subprocess.Popen(
        f"{openssl} x509 -noout -dates".split(),
        stdin=pssl.stdout,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    if (psslstdout := pssl.stdout) is not None:
        psslstdout.close()
    out = pparse.communicate()[0]
    notbefore = bmo.common.search_pat(r"notBefore=(.+?)\n", out)
    notafter = bmo.common.search_pat(r"notAfter=(.+?)\n", out)
    assert notbefore is not None
    assert notafter is not None
    notbefore = parse_x509_date(notbefore.group(1))
    notafter = parse_x509_date(notafter.group(1))
    timetoexpire = (notafter - dateutil.utils.today(notafter.tzinfo)).days
    assert timetoexpire >= 0, f"Certificate expired"
    bmo.common.success(f"Certificates look good.")
    typer.echo(f"days to expire={timetoexpire}")


if __name__ == "__main__":
    app(),
