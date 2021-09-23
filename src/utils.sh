run_only_test() {
  log "FUNCNAME=$FUNCNAME" "DEBUG"
  if [ "$BATS_TEST_NUMBER" -ne "$1" ]; then
    skip
  fi
}

teardown_test_case_tmp_dir() {
  log "FUNCNAME=$FUNCNAME" "DEBUG"\

  if [ $BATS_TEST_COMPLETED ]; then
    rm -rf $BATS_TEST_TMPDIR
    echo "Removed test case directory, as test case succeeded"
  else
    export BATS_TEST_FAILED=true
    echo "Did not delete $BATS_TEST_TMPDIR, as test failed"
  fi
}

teardown_test_file_tmp_dir() {
  log "FUNCNAME=$FUNCNAME" "DEBUG"

  if [ -n "$BATS_TEST_FAILED" ]; then 
    echo "Did not delete $BATS_FILE_TMPDIR, as atleast one test failed"
  else
    # rm -rf "$BATS_FILE_TMPDIR"
    echo "Removed test file directory, as test file succeeded"
  fi
}