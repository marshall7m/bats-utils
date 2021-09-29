#!/bin/bash
source "$( cd "$( dirname "$BASH_SOURCE[0]" )" && cd "$(git rev-parse --show-toplevel)" >/dev/null 2>&1 && pwd )/node_modules/bash-utils/load.bash"

clone_repo() {
	log "FUNCNAME=$FUNCNAME" "DEBUG"

    if [ "${#@}" -ne 2 ]; then
        log "Missing params" "ERROR"
        exit 1
    fi
    
	local clone_url=$1
	local clone_destination=$2

	if [ -z "$clone_destination" ]; then
		log "\$2 for git clone destination is not set" "ERROR"
		exit 1
	fi

	local_clone_git="$clone_destination/.git"

	if [ ! -d $local_clone_git ]; then
		git clone "$clone_url" "$clone_destination"
	else
		log ".git already exists in clone destination" "INFO"
	fi
}

setup_test_file_repo() {
	log "FUNCNAME=$FUNCNAME" "DEBUG"

	local clone_url=$1

	export BATS_FILE_TMPDIR="$(mktemp -d)"
	log "BATS_FILE_TMPDIR: $BATS_FILE_TMPDIR" "DEBUG"

	export TEST_FILE_REPO_DIR="$BATS_FILE_TMPDIR/test-repo"
	log "TEST_FILE_REPO_DIR: $TEST_FILE_REPO_DIR" "DEBUG"

	clone_repo $clone_url $TEST_FILE_REPO_DIR
}

setup_test_case_repo() {
	log "FUNCNAME=$FUNCNAME" "DEBUG"

	if [ -z "$TEST_FILE_REPO_DIR" ]; then
		log "TEST_FILE_REPO_DIR is not set" "ERROR"
		exit 1
	fi

	export TEST_CASE_REPO_DIR="$BATS_TEST_TMPDIR/test-repo"
	log "Cloning local template Github repo to test case tmp dir: $TEST_CASE_REPO_DIR" "INFO"
	clone_repo $TEST_FILE_REPO_DIR $TEST_CASE_REPO_DIR
}