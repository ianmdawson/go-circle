.PHONY: install test

STATICCHECK := $(GOPATH)/bin/staticcheck
BUMP_VERSION := $(GOPATH)/bin/bump_version
WRITE_MAILMAP := $(GOPATH)/bin/write_mailmap
RELEASE := $(GOPATH)/bin/github-release

install:
	go install ./...

build:
	go get ./...
	go build ./...

$(STATICCHECK):
	go get -u honnef.co/go/tools/cmd/staticcheck

lint: $(STATICCHECK)
	go vet ./...
	go list ./... | grep -v vendor | xargs $(STATICCHECK)

test: lint
	go test ./...

race-test: lint
	go test -race ./...

$(BUMP_VERSION):
	go get -u github.com/kevinburke/bump_version

$(RELEASE):
	go get -u github.com/aktau/github-release

release: test | $(BUMP_VERSION) $(RELEASE)
ifndef version
	@echo "Please provide a version"
	exit 1
endif
ifndef GITHUB_TOKEN
	@echo "Please set GITHUB_TOKEN in the environment"
	exit 1
endif
	$(BUMP_VERSION) --version=$(version) circle.go
	git push origin --tags
	mkdir -p releases/$(version)
	GOOS=linux GOARCH=amd64 go build -o releases/$(version)/circle-linux-amd64 ./circle
	GOOS=darwin GOARCH=amd64 go build -o releases/$(version)/circle-darwin-amd64 ./circle
	GOOS=windows GOARCH=amd64 go build -o releases/$(version)/circle-windows-amd64 ./circle
	# These commands are not idempotent, so ignore failures if an upload repeats
	$(RELEASE) release --user kevinburke --repo go-circle --tag $(version) || true
	$(RELEASE) upload --user kevinburke --repo go-circle --tag $(version) --name circle-linux-amd64 --file releases/$(version)/circle-linux-amd64 || true
	$(RELEASE) upload --user kevinburke --repo go-circle --tag $(version) --name circle-darwin-amd64 --file releases/$(version)/circle-darwin-amd64 || true
	$(RELEASE) upload --user kevinburke --repo go-circle --tag $(version) --name circle-windows-amd64 --file releases/$(version)/circle-windows-amd64 || true

$(WRITE_MAILMAP):
	go get -u github.com/kevinburke/write_mailmap

force: ;

AUTHORS.txt: force | $(WRITE_MAILMAP)
	$(WRITE_MAILMAP) > AUTHORS.txt

authors: AUTHORS.txt
