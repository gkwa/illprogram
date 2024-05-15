BIN := illprogram
SRC := $(wildcard *.go **/*.go)
CUE_SRC := $(wildcard *.cue **/*.cue)
DATE := $(shell date +"%Y-%m-%dT%H:%M:%SZ")
GOVERSION := $(shell go version)
VERSION := $(shell git describe --tags --abbrev=8 --dirty --always --long)
SHORT_SHA := $(shell git rev-parse --short HEAD)
FULL_SHA := $(shell git rev-parse HEAD)
export GOVERSION # goreleaser wants this
PREFIX := github.com/taylormonacelli/illprogram/version
LDFLAGS = -s -w
LDFLAGS += -X $(PREFIX).Version=$(VERSION)
LDFLAGS += -X '$(PREFIX).Date=$(DATE)'
LDFLAGS += -X '$(PREFIX).GoVersion=$(GOVERSION)'
LDFLAGS += -X $(PREFIX).ShortGitSHA=$(SHORT_SHA)
LDFLAGS += -X $(PREFIX).FullGitSHA=$(FULL_SHA)

.DEFAULT_GOAL := iterate

all: check $(BIN) install

.PHONY: iterate # lint and rebuild
iterate: check $(BIN)

.PHONY: check # lint and vet
check: .check_timestamp

.check_timestamp: tidy fmt lint vet
	@touch $@

.PHONY: build # build
build: $(BIN)

$(BIN): .build_timestamp
	go build -ldflags "$(LDFLAGS)" -o $@ main.go

.build_timestamp: $(SRC) $(CUE_SRC)
	@touch $@

.PHONY: goreleaser # run goreleaser
goreleaser: goreleaser --clean

.PHONY: tidy # go tidy
tidy: .tidy_timestamp

.tidy_timestamp: go.mod go.sum
	go mod tidy
	@touch $@

.PHONY: fmt # go fmt
fmt: .fmt_timestamp

.fmt_timestamp: $(SRC)
	gofumpt -w $(SRC)
	@touch $@

.PHONY: cue_fmt # cue fmt
cue_fmt: .cue_fmt_timestamp

.cue_fmt_timestamp: $(CUE_SRC)
	cue fmt $(CUE_SRC)
	@touch $@

.PHONY: lint # lint
lint: .lint_timestamp

.lint_timestamp: $(SRC)
	golangci-lint run
	@touch $@

.PHONY: vet # go vet
vet: .vet_timestamp

.vet_timestamp: $(SRC)
	go vet ./...
	@touch $@

.PHONY: install # go install
install: $(BIN)
	go install

.PHONY: help # show makefile rules
help:
	@grep '^.PHONY: .* #' Makefile | sed 's/\.PHONY: \(.*\) # \(.*\)/\1 \2/' | expand -t20

.PHONY: clean # clean bin
clean:
	$(RM) $(BIN) .build_timestamp .tidy_timestamp .fmt_timestamp .cue_fmt_timestamp .lint_timestamp .vet_timestamp .check_timestamp
