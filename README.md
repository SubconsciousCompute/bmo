[![PyPI version](https://badge.fury.io/py/bmo.svg)](https://badge.fury.io/py/bmo) [![Documentation Status](https://readthedocs.org/projects/subconscious-bmo/badge/?version=latest)](https://subconscious-bmo.readthedocs.io/en/latest/?badge=latest)

# BMO

__This is WIP.__

BMO automates stuff at SubCom. For details see the docs https://subconscious-bmo.readthedocs.io/en/latest/

# Simple Use case

- Run `gitlab-runner`.

```bash
bmo cicd runner 
```

- Check the certificates 

```bash

Traceback (most recent call last):
  File "<string>", line 1, in <module>
  File "/home/dilawars/PY37/lib/python3.7/site-packages/typer/main.py", line 214, in __call__
    return get_command(self)(*args, **kwargs)
  File "/home/dilawars/PY37/lib/python3.7/site-packages/click/core.py", line 1130, in __call__
    return self.main(*args, **kwargs)
  File "/home/dilawars/PY37/lib/python3.7/site-packages/click/core.py", line 1055, in main
    rv = self.invoke(ctx)
  File "/home/dilawars/PY37/lib/python3.7/site-packages/click/core.py", line 1657, in invoke
    return _process_result(sub_ctx.command.invoke(sub_ctx))
  File "/home/dilawars/PY37/lib/python3.7/site-packages/click/core.py", line 1657, in invoke
    return _process_result(sub_ctx.command.invoke(sub_ctx))
  File "/home/dilawars/PY37/lib/python3.7/site-packages/click/core.py", line 1404, in invoke
    return ctx.invoke(self.callback, **ctx.params)
  File "/home/dilawars/PY37/lib/python3.7/site-packages/click/core.py", line 760, in invoke
    return __callback(*args, **kwargs)
  File "/home/dilawars/PY37/lib/python3.7/site-packages/typer/main.py", line 500, in wrapper
    return callback(**use_params)  # type: ignore
  File "/home/dilawars/Work/GITHUB.COM/bmo/bmo/network.py", line 69, in check_ssl
    assert notbefore is not None
AssertionError
Sentry is attempting to send 2 pending error messages
Waiting up to 2 seconds
Press Ctrl-C to quit
