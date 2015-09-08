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
  unset aws_access_key
	unset aws_secret_key
	unset bucket_name
  unset ipa_path
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

# [TEST] Call the command with aws_access_key not set, 
# it should raise an error message and exit
# 
(
  print_new_test
  test_env_cleanup

  # Set env vars
  export aws_secret_key="dsa4321"
  export bucket_name="dsa4321"
  export ipa_path="$test_ipa_path"

  expect_success "aws_secret_key environment variable should be set" is_not_empty "$aws_secret_key"
  expect_success "bucket_name environment variable should be set" is_not_empty "$bucket_name"
  expect_success "ipa_path environment variable should be set" is_not_empty "$ipa_path"

  # Send sms request
  expect_error "The command should be called, but should not complete sucessfully" run_target_command
)
test_result=$?
inspect_test_result $test_result
