#!/bin/bash

#
# Run it from the directory which contains step.sh
#


# ------------------------
# --- Helper functions ---

function print_and_do_command {
  echo "$ $@"
  $@
}

function inspect_test_result {
  if [ $1 -eq 0 ]; then
    test_results_success_count=$[test_results_success_count + 1]
  else
    test_results_error_count=$[test_results_error_count + 1]
  fi
}

#
# First param is the expect message, other are the command which will be executed.
#
function expect_success {
  expect_msg=$1
  shift

  echo " -> $expect_msg"
  $@
  cmd_res=$?

  if [ $cmd_res -eq 0 ]; then
    echo " [OK] Expected zero return code, got: 0"
  else
    echo " [ERROR] Expected zero return code, got: $cmd_res"
    exit 1
  fi
}

#
# First param is the expect message, other are the command which will be executed.
#
function expect_error {
  expect_msg=$1
  shift

  echo " -> $expect_msg"
  $@
  cmd_res=$?

  if [ ! $cmd_res -eq 0 ]; then
    echo " [OK] Expected non-zero return code, got: $cmd_res"
  else
    echo " [ERROR] Expected non-zero return code, got: 0"
    exit 1
  fi
}

function is_dir_exist {
  if [ -d "$1" ]; then
    return 0
  else
    return 1
  fi
}

function is_file_exist {
  if [ -f "$1" ]; then
    return 0
  else
    return 1
  fi
}

function is_not_empty {
  if [[ $1 ]]; then
    return 0
  else
    return 1
  fi
}

function test_env_cleanup {
  unset S3_DEPLOY_AWS_ACCESS_KEY
	unset S3_DEPLOY_AWS_SECRET_KEY
	unset S3_BUCKET_NAME
  unset BITRISE_IPA_PATH
}

function print_new_test {
  echo
  echo "[TEST]"
}

function run_target_command { 
  print_and_do_command ruby ./s3deploy.rb
}


# -----------------
# --- Run tests ---

echo "Starting tests..."

test_ipa_path="tests/testfile.ipa"
test_results_success_count=0
test_results_error_count=0

# [TEST] Call the command with S3_DEPLOY_AWS_ACCESS_KEY not set, 
# it should raise an error message and exit
# 
(
  print_new_test
  test_env_cleanup

  # Set env vars
  export S3_DEPLOY_AWS_SECRET_KEY="dsa4321"
  export S3_BUCKET_NAME="dsa4321"
  export BITRISE_IPA_PATH="$test_ipa_path"

  # All env vars should exist except TWILIO_ACCOUNT_SID
  expect_error "TWILIO_ACCOUNT_SID environment variable should NOT be set" is_not_empty "$TWILIO_ACCOUNT_SID"
  expect_success "S3_DEPLOY_AWS_SECRET_KEY environment variable should be set" is_not_empty "$S3_DEPLOY_AWS_SECRET_KEY"
  expect_success "S3_BUCKET_NAME environment variable should be set" is_not_empty "$S3_BUCKET_NAME"
  expect_success "BITRISE_IPA_PATH environment variable should be set" is_not_empty "$BITRISE_IPA_PATH"

  # Send sms request
  expect_error "The command should be called, but should not complete sucessfully" run_target_command
)
test_result=$?
inspect_test_result $test_result
