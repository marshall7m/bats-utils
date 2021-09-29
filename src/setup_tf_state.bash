#!/bin/bash
source "$( cd "$( dirname "$BASH_SOURCE[0]" )" && cd "$(git rev-parse --show-toplevel)" >/dev/null 2>&1 && pwd )/node_modules/bash-utils/load.bash"

setup_test_file_tf_state() {
	log "FUNCNAME=$FUNCNAME" "DEBUG"

	# repo's git root path relative path to terragrunt parent directory
	local terragrunt_root_dir=$1
	if [ -z "$terragrunt_root_dir" ]; then
		log "terragrunt_root_dir is not set" "ERROR"
		exit 1
	elif [ -z "$TEST_FILE_REPO_DIR" ]; then
		log "TEST_FILE_REPO_DIR is not set" "ERROR"
		exit 1
	fi

	# applies all of repo's terragrunt configurations at test file level
	# test cases can just source from test file directory instead of reapplying terragrunt config for every test case
	export TESTING_LOCAL_PARENT_TF_STATE_DIR="$BATS_FILE_TMPDIR/test-file-repo-tf-state"

	log "Setting up test file tmp repo directory for tfstate" "INFO"
	log "TESTING_LOCAL_PARENT_TF_STATE_DIR: $TESTING_LOCAL_PARENT_TF_STATE_DIR" "DEBUG"
	
	abs_terragrunt_root_dir="$TEST_FILE_REPO_DIR/$terragrunt_root_dir"
	log "Absolute path to Terragrunt parent directory: $abs_terragrunt_root_dir"

	log "Applying all terragrunt repo configurations" "INFO"
	terragrunt run-all apply --terragrunt-non-interactive --terragrunt-working-dir "$abs_terragrunt_root_dir" -auto-approve 2>&1 || exit 1
}

setup_test_case_tf_state() {
	log "FUNCNAME=$FUNCNAME" "DEBUG"
	
	if [ -z "$TESTING_LOCAL_PARENT_TF_STATE_DIR" ]; then
		log "TESTING_LOCAL_PARENT_TF_STATE_DIR is not set -- run setup_test_file_tf_state()" "ERROR"
		exit 1
	fi
	#creates persistent local tf state for test case repo even when test repo commits are checked out (see test repo's parent terragrunt file generate backend block)
    test_case_tf_state_dir="$BATS_TEST_TMPDIR/test-repo-tf-state"
	log "Test case tf state dir: $test_case_tf_state_dir" "INFO"

	log "Copying test file's terraform state file structure to test case repo tmp dir" "INFO"
	cp -rv "$TESTING_LOCAL_PARENT_TF_STATE_DIR" "$test_case_tf_state_dir"

	#redirect tf state files to test case dir instead of test file dir
	export TESTING_LOCAL_PARENT_TF_STATE_DIR="$test_case_tf_state_dir"
}