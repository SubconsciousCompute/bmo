__author__           = "Dilawar Singh"
__email__            = "dilawar@subcom.tech"

try:
    from importlib.metadata import version
except ImportError:
    from importlib_metadata import version

__version__ = version('bmo')
