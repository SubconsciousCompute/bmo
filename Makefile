PYTHON := $(shell which python)
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

lint:
	$(POETRY) install
	$(POETRY) run mypy $(MYPY_OPTS) bmo

## Tests

test: test_cli test_module

test_module: 
	$(POETRY) install
	$(POETRY) run bmo --help
	$(POETRY) run pytest tests/*.py

test_cli: test_module
	$(POETRY) run bmo run lint
	$(POETRY) run bmo run gi
	$(POETRY) run bmo network check_ssl https://subcom.link



.PHONY : bmo fix test install lint build all
