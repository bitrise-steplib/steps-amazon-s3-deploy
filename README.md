steps-amazon-s3-deploy
======================

BITRISE Step to Deploy an Xcode Archive (IPA) to Amazon S3.

Generates the related Plist, and generates an email-ready install URL which can be opened on an iOS device to download the app.

This Step depends on steps-xcode-builder's Archive step

This Step requires an Amazon S3 registration. To register an Amazon S3 account, [click here](http://aws.amazon.com/s3/)

This Step is part of the [Open StepLib](http://www.steplib.com/), you can find its StepLib page [here](http://www.steplib.com/step/amazon-s3-deploy)


# Input Environment Variables

See the **step.yml** description file


# Output Environment Variables

See the **step.yml** description file

# Note

Uses the s3cmd utility, installed through [homebrew](http://brew.sh/).


# How to test?

$ BITRISE_IPA_PATH=[path] BITRISE_DSYM_PATH=[path] BITRISE_APP_SLUG=appslug1234 BITRISE_APP_TITLE=apptitle BITRISE_BUILD_SLUG=buildslug1234 S3_DEPLOY_AWS_ACCESS_KEY=[access-key] S3_DEPLOY_AWS_SECRET_KEY=[secret-key] S3_BUCKET_NAME=[bucket] bash step.sh