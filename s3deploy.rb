require 'rubygems'
require 'aws-sdk'

options = {
	status: ENV['CONCRETE_ARCHIVE_STATUS'],
	ipa: ENV['CONCRETE_IPA_PATH'],
	dsym: ENV['CONCRETE_DSYM_PATH'],
	app_slug: ENV['CONCRETE_APP_SLUG'],
	app_title: ENV['CONCRETE_APP_TITLE'],
	build_slug: ENV['CONCRETE_BUILD_SLUG'],
	access_key: ENV['S3_DEPLOY_AWS_ACCESS_KEY'],
	secret_key: ENV['S3_DEPLOY_AWS_SECRET_KEY'],
	bucket_name: ENV['S3_BUCKET_NAME'],
	region_name: ENV['S3_REGION_NAME'],
	path_in_bucket: ENV['S3_PATH_IN_BUCKET']
}

p "Options: #{options}"

begin
	# checks
	#
	# ipa
	unless File.exists?(options[:ipa])
  	puts "No IPA found to deploy. Terminating."
  	exit!
	end
	# access_key
	unless options[:access_key]
  	puts "No AWS access key provided. Terminating."
  	exit!
	end
	# secret_key
	unless options[:secret_key]
  	puts "No AWS secret key provided. Terminating."
  	exit!
	end

	AWS.config(
  	:access_key_id => options[:access_key], 
  	:secret_access_key => options[:secret_key],
  	:region => options[:region_name]
	)

	s3 = AWS::S3.new

	# define path
	path = ""
	if (options[:path_in_bucket])
		path = options[:path_in_bucket]
	else
		path = "concrete_#{options[:app_title]}_#{options[:app_slug]}/build_#{options[:build_slug]}/"
	end

	# ipa upload
	s3.buckets[options[:bucket_name]].objects[path].write(:file => options[:ipa])
	puts "Uploading ipa #{options[:ipa]} to bucket #{options[:bucket_name]}. Path= #{path}"

	# dsym upload
	if File.exists?(options[:dsym])
		s3.buckets[options[:bucket_name]].objects[path].write(:file => options[:dsym])
		puts "Uploading dsym #{options[:dsym]} to bucket #{options[:bucket_name]}. Path= #{path}"
	end

rescue => ex
	puts "Exception happened: #{ex}"
	exit 1
end