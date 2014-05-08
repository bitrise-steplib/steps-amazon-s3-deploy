steps-amazon-s3-deploy
======================

Concrete Step to Deploy an xcode archive to Amazon S3

This Step depends on steps-xcode-builder's Archive step

# Input Environment Variables
- CONCRETE_ARCHIVE_STATUS 	(passed automatically)
- CONCRETE_IPA_PATH			(passed automatically)
- CONCRETE_DSYM_PATH		(passed automatically)

- S3_DEPLOY_AWS_ACCESS_KEY
- S3_DEPLOY_AWS_SECRET_KEY
- S3_BUCKET_NAME
