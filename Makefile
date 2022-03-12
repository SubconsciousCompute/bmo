all : build


build:
	nimble build


test:
	testament pattern "tests/test_*.nim"
