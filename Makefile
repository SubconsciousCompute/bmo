all : lint build


build:
	poetry install
	poetry build 

lint:
	poetry install
	poetry run mypy --ignore-missing-imports bmo
	poetry run pylint -E bmo tests

install:
	poetry install 


test:
	poetry install 
	poetry run pytest tests
	poetry run bmo --help

fix:
	poetry run black bmo
	poetry run black tests
