#!/bin/bash
source "$( cd "$( dirname "$BASH_SOURCE[0]" )" && cd "$(git rev-parse --show-toplevel)" >/dev/null 2>&1 && pwd )/node_modules/bash-utils/load.bash"

setup_terragrunt_branch_tracking() {
	# Used for cleaning up testing resources when resources are applied via Terragrunt within different git branches
	# Creates an alias Terragrunt function to track branches Terragrunt was used in
	# Use teardown_tf_state() to destroy the branches' resources

	# WARNING:
	# All resources defined within the tracked branches will be destroyed
	# Be sure not to create Terragrunt dependencies within repos outside of target repo as those dependencies will also be destroyed

	# Possible Limitations:
	# - Changing backend type within a commit may break teardown_tf_state() terragrunt destroy command for commits prior to backend changes

	log "FUNCNAME=$FUNCNAME" "DEBUG"

	log "Creating Terragrunt alias function" "INFO" 
	terragrunt() {
		#TODO: do check to see if tg working dir is in TEST_FILE_REPO_DIR or TEST_CASE_REPO_DIR
		branch=$(cd "$tg_dir" && git rev-parse --abbrev-ref HEAD)

		if [ -z "$TERRAGRUNT_ROLLBACK_BRANCHES" ]; then TERRAGRUNT_ROLLBACK_BRANCHES=(); fi
		set -f
		TERRAGRUNT_ROLLBACK_BRANCHES=(${TERRAGRUNT_ROLLBACK_BRANCHES// / })
		TERRAGRUNT_ROLLBACK_BRANCHES+=("$branch")
		set +f
		export TERRAGRUNT_ROLLBACK_BRANCHES=$(echo "$TERRAGRUNT_ROLLBACK_BRANCHES")
		
		"$(which terragrunt)" "$@"
	}
	export -f terragrunt
}

teardown_tf_state() {
	log "FUNCNAME=$FUNCNAME" "DEBUG"
	
	if [ -z "$TEST_FILE_REPO_DIR" ]; then
		log "TEST_FILE_REPO_DIR is not set" "ERROR"
		exit 1
	fi

	set -f
	TERRAGRUNT_ROLLBACK_BRANCHES=(${TERRAGRUNT_ROLLBACK_BRANCHES// / })
	set +f

	log "Destroying all test file terragrunt repo configurations" "INFO"
	for branch in "${TERRAGRUNT_ROLLBACK_BRANCHES[@]}"; do
		log "Branch: $branch" "DEBUG"
		git checkout "$branch"
		terragrunt run-all destroy --terragrunt-non-interactive --terragrunt-working-dir "$TEST_CASE_REPO_DIR" -auto-approve 2>&1
		git switch -
	done

	unset -f terragrunt
}


