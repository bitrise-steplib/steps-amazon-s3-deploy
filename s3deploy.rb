require 'rubygems'
require 'aws-sdk'

options = {
						 ipa: ENV['BITRISE_IPA_PATH'],
						dsym:	ENV['BITRISE_DSYM_PATH'],
				app_slug: ENV['BITRISE_APP_SLUG'],
			 app_title: ENV['BITRISE_APP_TITLE'],
			build_slug: ENV['BITRISE_BUILD_SLUG'],
			access_key:	ENV['S3_DEPLOY_AWS_ACCESS_KEY'],
			secret_key:	ENV['S3_DEPLOY_AWS_SECRET_KEY'],
		 bucket_name:	ENV['S3_BUCKET_NAME'],
		 region_name:	ENV['S3_REGION_NAME'],
	path_in_bucket: ENV['S3_PATH_IN_BUCKET'],
						 acl: ENV['S3_FILE_ACCESS_LEVEL']
}

p "Options: #{options}"

status = "success"
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

	# define object path
	path = ""
	if (options[:path_in_bucket])
		path = options[:path_in_bucket] + "/"
	else
		path = "bitrise_#{options[:app_title]}_#{options[:app_slug]}/build_#{options[:build_slug]}/"
	end

	puts path

	access_level = 'public_read'
	if (options[:acl])
		access_level = options[:acl]
	end

	# ipa upload
	s3.buckets[options[:bucket_name]].objects[path + File.basename(options[:ipa])].write(:file => options[:ipa], :acl => access_level)
	puts "Uploading ipa #{options[:ipa]} to bucket #{options[:bucket_name]}."

	# dsym upload
	if File.exists?(options[:dsym])
		s3.buckets[options[:bucket_name]].objects[path + File.basename(options[:dsym])].write(:file => options[:dsym], :acl => access_level)
		puts "Uploading dsym #{options[:dsym]} to bucket #{options[:bucket_name]}."
	end

	# public url
	# TODO consider using url_for
	public_url = s3.buckets[options[:bucket_name]].objects[path].public_url
	public_url_ipa = s3.buckets[options[:bucket_name]].objects[path + File.basename(options[:ipa])].public_url
	public_url_dsym = s3.buckets[options[:bucket_name]].objects[path + File.basename(options[:dsym])].public_url
	
	# output variables
	File.open(File.join(ENV['HOME'], '.bash_profile'), 'a') { |f| f.write("export S3_DEPLOY_STEP_URL_IPA=\"#{public_url_ipa}\"\n") }
	File.open(File.join(ENV['HOME'], '.bash_profile'), 'a') { |f| f.write("export S3_DEPLOY_STEP_URL_DSYM=\"#{public_url_dsym}\"\n") }

	ENV['S3_DEPLOY_STEP_URL_IPA'] = "#{public_url_ipa}"

	# plist generation - we have to run it after we have obtained the public url to the ipa
	system("sh ./gen_plist.sh")

	# plist upload
	plist_path = options[:app_title] + ".plist"

	if File.exists?(plist_path)
		s3.buckets[options[:bucket_name]].objects[path + plist_path].write(:file => plist_path, :acl => access_level)
		puts "Uploading plist #{plist_path} to bucket #{options[:bucket_name]}."
	else
		puts "NO PLIST :<"
	end

	public_url_plist = s3.buckets[options[:bucket_name]].objects[path + plist_path].public_url

	File.open(File.join(ENV['HOME'], '.bash_profile'), 'a') { |f| f.write("export S3_DEPLOY_STEP_URL_PLIST=\"#{public_url_plist}\"\n") }
	File.open(File.join(ENV['HOME'], '.bash_profile'), 'a') { |f| f.write("export S3_DEPLOY_STEP_EMAIL_READY_URL=\"itms-services://?action=download-manifest&url=#{public_url_plist}\"\n") }

rescue => ex
	puts "Exception happened: #{ex}"
	status = "failed"
	exit 1
ensure
	File.open(File.join(ENV['HOME'], '.bash_profile'), 'a') { |f| f.write("export S3_DEPLOY_STEP_STATUS=\"#{status}\"\n") }
	puts "status=" + status
end