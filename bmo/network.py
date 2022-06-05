# Wifi module

import datetime

import typer

from loguru import logger

app = typer.Typer()


class WifiConnection:
    """docstring for WifiConnection"""

    def __init__(self):
        logger.info("WiFi connection")
        self.last_tested_on = datetime.datetime.now()

    def speed_test(self):
        now = datetime.datetime.now()
        if now - self.last_tested_on < 100:
            logger.warning("Called too soon")
            return False
        logger.info("Calling speedtest")
        return True


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
