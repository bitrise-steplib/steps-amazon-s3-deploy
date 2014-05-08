require 'rubygems'
require 'aws-sdk'

options = {
  status: ENV['CONCRETE_ARCHIVE_STATUS'],
  ipa: ENV['CONCRETE_IPA_PATH'],
	dsym: ENV['CONCRETE_DSYM_PATH'],
	access_key: ENV['S3_DEPLOY_AWS_ACCESS_KEY'],
	secret_key: ENV['S3_DEPLOY_AWS_SECRET_KEY'],
	bucket_name: ENV['S3_BUCKET_NAME']
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
  	:secret_access_key => options[:secret_key]
	)

	s3 = AWS::S3.new

	# ipa upload
	s3.buckets[options[:bucket_name]].objects[File.basename(options[:ipa])].write(:file => options[:ipa])
	puts "Uploading ipa #{options[:ipa]} to bucket #{options[:bucket_name]}."

	# dsym upload
	if File.exists?(options[:dsym])
		s3.buckets[options[:bucket_name]].objects[File.basename(options[:dsym])].write(:file => options[:dsym])
		puts "Uploading dsym #{options[:dsym]} to bucket #{options[:bucket_name]}."
	end

rescue => ex
	puts "Exception happened: #{ex}"
	exit 1
end