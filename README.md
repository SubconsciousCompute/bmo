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
$ bmo run network ssl-check subcom.tech
:) Certificates look good.
days to expire=73
```
