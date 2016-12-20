#!/usr/bin/env bash

set -e

function info {
    echo -e "$(date +'%F %T'): $@"
}

# Check for stylistic issues using golint
function golint {
    set +e
    LINT=$($GOPATH/bin/golint . | grep -v ".pb.*.go:")
    set -e
    if [[ ! -z $LINT ]]; then
        IFS=$'\n'
        for LINE in $LINT; do
            info "$LINE"
        done

        info "detected golint issues, failing build"
	return 1
    fi

    return 0
}

info "running govet checks..."
go vet -x ./...

info "running golint checks..."
golint

info "running tests..."
go test -v ./...
info "done running tests"
sleep 3

info "running tests with race flag..."
go test -v -race ./...
info "done running tests with race flag"
sleep 5

info "running tests with cover flag..."
set +e
go test -v -cover ./...
info "done tests with cover flag"
set -e
