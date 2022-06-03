all :


lint:
	poetry run mypy bmo
	poetry run pylint -E .
