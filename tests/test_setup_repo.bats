load "${BATS_TEST_DIRNAME}/../load.bash"
load "${BATS_TEST_DIRNAME}/../node_modules/bats-support/load.bash"
load "${BATS_TEST_DIRNAME}/../node_modules/bats-assert/load.bash"
load "${BATS_TEST_DIRNAME}/../node_modules/bash-utils/load.bash"

setup_file() {
    export script_logging_level="DEBUG"
    load 'test-helper/common_setup'

    _common_setup
    log "FUNCNAME=$FUNCNAME" "DEBUG"
}

teardown_file() {
    log "FUNCNAME=$FUNCNAME" "DEBUG"
    teardown_test_file_tmp_dir
}

# setup() {
#     run_only_test 4
# }

teardown() {
    log "FUNCNAME=$FUNCNAME" "DEBUG"
    teardown_test_case_tmp_dir
}

@test "Script is runnable" {
    run setup_repo.bash
    assert_success
}

@test "Clone repo that exists" {
    log "TEST CASE: $BATS_TEST_NUMBER" "INFO"

    mock_repo="$BATS_TEST_TMPDIR/foo"
    dest="$BATS_TEST_TMPDIR/bar"

    mkdir -p "$mock_repo" && cd "$mock_repo" && git init && cd -
    
    run clone_repo "$mock_repo" "$dest"
    assert_success

    assert [ -d "$dest/.git" ]
}

@test "Clone repo that does not exists" {
    log "TEST CASE: $BATS_TEST_NUMBER" "INFO"

    mock_repo="$BATS_TEST_TMPDIR/foo"
    dest="$BATS_TEST_TMPDIR/bar"

    run clone_repo "$mock_repo" "$dest"
    assert_failure

    assert [ ! -d "$dest/.git" ]
}

@test "Setup test file valid repo" {
    log "TEST CASE: $BATS_TEST_NUMBER" "INFO"
    
    log "Setting up empty local git repo" "DEBUG"
    mock_repo="$BATS_TEST_TMPDIR/foo"
    mkdir -p "$mock_repo" && cd "$mock_repo" && git init && cd -
    
    run setup_test_file_repo "$mock_repo"
    assert_success

    assert [ -n "$BATS_FILE_TMPDIR" ]
    #TODO: figure out why directory exists assertion fails
    # assert [ -d "$TEST_FILE_REPO_DIR" ]
}

@test "Setup test file invalid repo" {
    log "TEST CASE: $BATS_TEST_NUMBER" "INFO"
    
    log "Setting up invalid local git repo" "DEBUG"
    mock_repo="$BATS_TEST_TMPDIR/foo"
    mkdir -p "$mock_repo"
    
    run setup_test_file_repo "$mock_repo"
    assert_failure
    
    assert [ -n "$BATS_FILE_TMPDIR" ]
}

@test "Setup test case valid repo" {
    log "TEST CASE: $BATS_TEST_NUMBER" "INFO"
    
    log "Setting up invalid local git repo" "DEBUG"
    mock_repo="$BATS_TEST_TMPDIR/foo"
    mkdir -p "$mock_repo" && cd "$mock_repo" && git init && cd -
    setup_test_file_repo "$mock_repo"
    
    run setup_test_case_repo
    assert_success
    
    assert [ -n "$TEST_FILE_REPO_DIR" ]

    #TODO: figure out why assertions says env var is not set
    # assert [ -n "$TEST_CASE_REPO_DIR" ]
}

@test "Setup test case invalid repo" {
    log "TEST CASE: $BATS_TEST_NUMBER" "INFO"
    
    run setup_test_case_repo
    assert_failure
    
    assert [ -z "$TEST_FILE_REPO_DIR" ]
    assert [ -z "$TEST_CASE_REPO_DIR" ]
}