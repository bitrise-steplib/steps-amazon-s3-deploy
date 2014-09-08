#!/bin/bash

ruby ./s3deploy.rb
exit_res=$?

form_out_cont=$(cat "${BITRISE_STEP_FORMATTED_OUTPUT_FILE_PATH}")
echo " (debug) Formatted output: ${form_out_cont}"

exit ${exit_res}