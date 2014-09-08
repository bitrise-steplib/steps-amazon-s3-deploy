steps-amazon-s3-deploy
======================

BITRISE Step to Deploy an Xcode Archive (IPA) to Amazon S3.

Generates the related Plist, and generates an email-ready install URL which can be opened on an iOS device to download the app.

This Step depends on steps-xcode-builder's Archive step


# Input Environment Variables

See the **step.yml** description file


# Output Environment Variables

See the **step.yml** description file


# How to test?

$ BITRISE_IPA_PATH=[path] BITRISE_DSYM_PATH=[path] BITRISE_APP_SLUG=appslug1234 BITRISE_APP_TITLE=apptitle BITRISE_BUILD_SLUG=buildslug1234 S3_DEPLOY_AWS_ACCESS_KEY=[access-key] S3_DEPLOY_AWS_SECRET_KEY=[secret-key] S3_BUCKET_NAME=[bucket] bash step.sh