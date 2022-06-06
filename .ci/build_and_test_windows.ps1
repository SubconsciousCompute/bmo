python -m ensurepip
python -m pip install poetry
python -m poetry install
python -m poetry build
python -m poetry test
python -m poetry run mypy --ignore-missing-imports bmo
python -m poetry run mypy --ignore-missing-imports tests
python -m poetry run bmo --help
