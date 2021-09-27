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

teardown() {
    log "FUNCNAME=$FUNCNAME" "DEBUG"
    teardown_test_case_tmp_dir
}

@test "Script is runnable" {
    run clone_repo.bash
    assert_failure
}


@test "Missing param" {
    run clone_repo.bash "foo"
    assert_failure
}

@test "Clone repo that exists" {
    log "TEST CASE: $BATS_TEST_NUMBER" "INFO"

    mock_repo="$BATS_TEST_TMPDIR/foo"
    dest="$BATS_TEST_TMPDIR/bar"

    mkdir -p "$mock_repo" && cd "$mock_repo" && git init && cd -
    
    run clone_repo.bash "$mock_repo" "$dest"
    assert_success

    assert [ -d "$dest/.git" ]
}

@test "Clone repo that does not exists" {
    mock_repo="$BATS_TEST_TMPDIR/foo"
    dest="$BATS_TEST_TMPDIR/bar"

    run clone_repo.bash "$mock_repo" "$dest"
    assert_failure

    assert [ ! -d "$dest/.git" ]
}

