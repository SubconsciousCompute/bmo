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

lint:
	$(POETRY) install
	$(POETRY) run mypy $(MYPY_OPTS) bmo

install:
	$(POETRY) install

test: lint
	$(POETRY) install
	$(POETRY) run pytest tests
	$(POETRY) run bmo --help

fix:
	$(POETRY) run black bmo
	$(POETRY) run black tests

upload: build
	$(PYTHON) -m pip install twine --user --upgrade
	$(PYTHON) -m twine upload dist/*.whl --user __token__ --password $(PYPI_UPLOAD_TOKEN)

bmo:
	$(POETRY) run bmo $(arg1) $(arg2)

.PHONY : bmo fix test install lint build all
