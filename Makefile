all : build

build:
	nimble build

test: build
	nimble test 

