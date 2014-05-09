#!/bin/bash

# not needed yet
# SSL certificate fix so it can be executed in an isolated, non admin user
#curl http://curl.haxx.se/ca/cacert.pem > $HOME/cacert.pem
#export SSL_CERT_FILE=$HOME/cacert.pem

bundle install
ruby ./s3deploy.rb
exit $?