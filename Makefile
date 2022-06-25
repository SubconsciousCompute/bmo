PYTHON := $(shell which python3)
POETRY := $(PYTHON) -m poetry

MYPY_OPTS:=--ignore-missing-imports --install-types --non-interactive

all : lint build

bootstrap:
	$(PYTHON) -m ensurepip
	$(PYTHON) -m pip install poetry

build:
	$(POETRY) install
	$(POETRY) build

install:
	$(POETRY) install

## DevOps

fix:
	$(POETRY) run black bmo
	$(POETRY) run black tests

upload: build
	$(PYTHON) -m pip install twine --user --upgrade
	$(PYTHON) -m twine upload dist/*.whl --user __token__ --password $(PYPI_UPLOAD_TOKEN)

check: mypy lint

mypy:
	$(POETRY) install
	$(POETRY) run mypy $(MYPY_OPTS) bmo tests

lint:
	$(POETRY) run pylint -E bmo tests

install:
	$(PYTHON) -m pip install .

## Tests
test: test_cli test_module

test_module:
	$(POETRY) install
	$(POETRY) run bmo --help
	$(POETRY) run pytest tests/*.py

test_cli: test_module
	$(POETRY) run bmo run lint
	$(POETRY) run bmo run gi
	$(POETRY) run bmo network check-ssl https://subcom.link


# CICD pipeline
ci:
	python -m pip install poetry --upgrade
	poetry install
	$(MAKE) check
	$(MAKE) test

docs doc:
	$(PYTHON) -m pip install -r docs/requirements.txt
	mkdocs build


.PHONY : bmo fix test install lint build all mypy check ci docs doc
