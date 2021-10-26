load "${BATS_TEST_DIRNAME}/../load.bash"
load "${BATS_TEST_DIRNAME}/../node_modules/bats-support/load.bash"
load "${BATS_TEST_DIRNAME}/../node_modules/bats-assert/load.bash"
load "${BATS_TEST_DIRNAME}/../node_modules/bash-utils/load.bash"

setup_file() {
    export script_logging_level="DEBUG"
    load 'test-helper/common_setup'

    _common_setup
    log "FUNCNAME=$FUNCNAME" "DEBUG"

    setup_test_file_repo "https://github.com/marshall7m/infrastructure-live-testing-template.git"
}

setup() {
    setup_test_case_repo

    export TESTING_LOCAL_PARENT_TF_STATE_DIR="$TEST_CASE_REPO_DIR"
}

teardown_file() {
    log "FUNCNAME=$FUNCNAME" "DEBUG"
    teardown_test_file_tmp_dir
}

teardown() {
    log "FUNCNAME=$FUNCNAME" "DEBUG"
    teardown_test_case_tmp_dir
}

@test "Script is runnable" {
    run teardown_tf_state.bash
    assert_success
}

@test "Destroy new branch and master branch Terragrunt configurations" {
    setup_terragrunt_branch_tracking

    cd "$TEST_FILE_REPO_DIR"
    log "Applying Terragrunt command on base branch" "DEBUG"
    testing_commit_ids+=($(git rev-parse --abbrev-ref HEAD))
    terragrunt run-all apply --terragrunt-non-interactive --terragrunt-working-dir "$TEST_FILE_REPO_DIR/directory_dependency/dev-account" -auto-approve
    
    log "Applying Terragrunt command on new branch" "DEBUG"
    git checkout -B "test-case-$BATS_TEST_NUMBER" > /dev/null
    terragrunt apply --terragrunt-non-interactive --terragrunt-working-dir "$TEST_FILE_REPO_DIR/directory_dependency/dev-account/global" -auto-approve
    testing_commit_ids+=($(git rev-parse --abbrev-ref HEAD))
    cd - > /dev/null
    
    run teardown_tf_state
    assert_success

    log "Assert env vars are set" "INFO"
    run : ${TERRAGRUNT_ROLLBACK_BRANCHES:?"TERRAGRUNT_ROLLBACK_BRANCHES not set or is an empty string"}
    assert_success

    log "Asserting terragrunt branch tracking is accurate" "INFO"
    log "Testing branches: $(printf '\n\t%s' "${testing_commit_ids[@]}")" "DEBUG"
    log "TERRAGRUNT_ROLLBACK_BRANCHES: $(printf '\n\t%s' "${TERRAGRUNT_ROLLBACK_BRANCHES[@]}")" "DEBUG"
    run [ "$TERRAGRUNT_ROLLBACK_BRANCHES" == "$testing_commit_ids" ]
    assert_success

    #TODO:
    log "Assert Terragrunt configurations were destroyed" "INFO"
}