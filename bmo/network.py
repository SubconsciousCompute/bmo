# network module
__author__ = "Dilawar Singh"

__email__ = "dilawar@subcom.tech"

import re
import datetime
import requests

import logging

import typer

app = typer.Typer()

import bmo.common


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
    openssl = bmo.common.find_program("openssl")
    assert openssl is not None
    out = bmo.common.run_command(
        f"{openssl} s_client -servername {server} -connect {server}:{port} | {openssl} x509 -noout -dates",
        silent=True,
    )

    vrc = bmo.common.search_pat(r"Verify return code:.+?\s", out)
    assert vrc, f"Verification failed."
    bmo.common.success("Verification of Certification passed.")


if __name__ == "__main__":
    app()
