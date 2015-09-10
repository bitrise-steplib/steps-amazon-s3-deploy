#!/bin/bash

THIS_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# s3cmd OS X fix
bash "${THIS_SCRIPT_DIR}/__s3cmd_osx_fix.sh"
if [ $? -ne 0 ] ; then
	echo "[!] Failed to apply required s3cmd fix"
	exit 1
fi

ruby "${THIS_SCRIPT_DIR}/s3deploy.rb"
exit $?
