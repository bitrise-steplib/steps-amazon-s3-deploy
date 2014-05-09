steps-amazon-s3-deploy
======================

Concrete Step to Deploy an xcode archive to Amazon S3

This Step depends on steps-xcode-builder's Archive step

# Input Environment Variables
- CONCRETE_ARCHIVE_STATUS 	(passed automatically)
- CONCRETE_IPA_PATH			(passed automatically)
- CONCRETE_DSYM_PATH		(passed automatically)
- CONCRETE_APP_SLUG			(passed automatically)
- CONCRETE_APP_TITLE		(passed automatically)
- CONCRETE_BUILD_SLUG		(passed automatically)

- S3_DEPLOY_AWS_ACCESS_KEY
- S3_DEPLOY_AWS_SECRET_KEY
- S3_BUCKET_NAME
- S3_REGION_NAME			(optional)
- S3_PATH_IN_BUCKET			(optional, default = concrete_{app_title}_{app_slug}/build_{build_slug})
- S3_FILE_ACCESS_LEVEL		[default=public_read] possible values: 
	private
	public_read
	public_read_write
	authenticated_read
	bucket_owner_read
	bucket_owner_full_control

# Output Environment Variables
- CONCRETE_DEPLOY_URL
- CONCRETE_DEPLOY_STATUS=[success/failed]

- S3_DEPLOY_STEP_URL
- S3_DEPLOY_STEP_STATUS=[success/failed]