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
    run setup_tf_state.bash
    assert_success
}