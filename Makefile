all : build doc

build:
	nimble build

test: build
	nimble test 

doc:
	nimble html

release:
	nimble build -d:release --opt:size  
