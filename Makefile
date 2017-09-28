# Makefile for Truss.
#
SHA := $(shell git rev-parse --short=10 HEAD)

MAKEFILE_PATH := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
VERSION_DATE := $(shell $(MAKEFILE_PATH)/commit_date.sh)

# Build native Truss by default.
default: truss

dependencies:
	go get github.com/gogo/protobuf/proto
	go get github.com/gogo/protobuf/jsonpb
	go get github.com/gogo/protobuf/gogoproto
	go get github.com/gogo/protobuf/protoc-gen-gogofast
	go get github.com/jteeuwen/go-bindata/...

update-dependencies:
	go get -u github.com/gogo/protobuf/proto
	go get -u github.com/gogo/protobuf/jsonpb
	go get -u github.com/gogo/protobuf/gogoproto
	go get -u github.com/gogo/protobuf/protoc-gen-gogofast
	go get -u github.com/golang/protobuf/proto
	go get -u github.com/jteeuwen/go-bindata/...

# Generate go files containing the all template files in []byte form
gobindata:
	go generate github.com/TuneLab/truss/gengokit/template

# Install truss and protoc-gen-truss-protocast
truss: gobindata
	go install github.com/TuneLab/truss/cmd/protoc-gen-truss-protocast
	go install -ldflags '-X "main.Version=$(SHA)" -X "main.VersionDate=$(VERSION_DATE)"' github.com/TuneLab/truss/cmd/truss

# Run the go tests and the truss integration tests
test: test-go test-integration

test-go:
	go test -v ./...

test-integration:
	$(MAKE) -C cmd/_integration-tests

# Removes generated code from tests
testclean:
	$(MAKE) -C cmd/_integration-tests clean

.PHONY: testclean test-integration test-go test truss gobindata dependencies
