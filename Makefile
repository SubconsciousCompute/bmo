PYTHON := $(shell which python3)
POETRY := $(PYTHON) -m poetry

all : lint build


build:
	$(POETRY) install
	$(POETRY) build

lint:
	$(POETRY) install
	$(POETRY) run mypy --ignore-missing-imports bmo
	# $(POETRY) run pylint -E bmo tests

install:
	$(POETRY) install


test:
	$(POETRY) install
	$(POETRY) run pytest tests
	$(POETRY) run bmo --help

fix:
	$(POETRY) run black bmo
	$(POETRY) run black tests

bmo:
	$(POETRY) run bmo $(arg1) $(arg2)

.PHONY : bmo fix test install lint build all
