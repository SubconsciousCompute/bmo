all : lint build


build:
	poetry install
	poetry build 

lint:
	poetry install
	poetry run mypy --ignore-missing-imports bmo
	poetry run pylint -E bmo tests
