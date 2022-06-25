# network module
__author__ = "Dilawar Singh"
__email__ = "dilawar@subcom.tech"

import logging
import subprocess
from urllib.parse import urlparse

import dateutil.parser
import dateutil.utils

import typer

app = typer.Typer()

import bmo.common


def parse_x509_date(datestr: str):
    return dateutil.parser.parse(datestr)


@app.command()
def speedtest():
    import speedtest as _st

    logging.info("Running speedtest")
    s = _st.Speedtest()
    s.get_servers([])
    s.get_best_server()
    s.download(threads=None)
    s.upload(threads=None)
    try:
        s.results.share()
    except Exception as e:
        logging.warn(f"{e}")
    res = s.results.dict()
    res["download"] = res["download"] / 1024 / 1024
    res["upload"] = res["download"] / 1024 / 1024
    print(res)


@app.command()
def check_ssl(server: str, port: int = 443):
    """Check SSL certificate of a given url."""
    if not server.startswith("https"):
        server = f"https://{server}"
    logging.info(f"Checking certificate for {server}")
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
    out = pparse.communicate()[0]
    logging.info(f"out={out}")
    notbefore = bmo.common.search_pat(r"notBefore=(.+?)\n", out)
    notafter = bmo.common.search_pat(r"notAfter=(.+?)\n", out)
    assert notbefore is not None, out
    assert notafter is not None, out
    notbefore = parse_x509_date(notbefore.group(1))
    notafter = parse_x509_date(notafter.group(1))
    timetoexpire = (notafter - dateutil.utils.today(notafter.tzinfo)).days
    assert timetoexpire >= 0, f"Certificate expired"
    bmo.common.success(f"Certificates look good.")
    typer.echo(f"days to expire={timetoexpire}")


if __name__ == "__main__":
    app()
