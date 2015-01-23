#!/bin/bash

#
# [!] Required fix for s3cmd 1.5.0 on OS X
#

echo " => Creating symlink for python to as 'python2' from 'python2.7'"

if [ -x '/usr/bin/python2' ] ; then
	echo " (i) /usr/bin/python2 already exists and executable - no fix needed"
	exit 0
fi

echo " (i) No /usr/bin/python2 executable found - creating symlink from python2.7"

cd /usr/bin
sudo ln python2.7 python2
exit $?