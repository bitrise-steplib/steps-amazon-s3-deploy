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


$formatted_output_file_path = ENV['BITRISE_STEP_FORMATTED_OUTPUT_FILE_PATH']

def puts_string_to_formatted_output(text)
	open($formatted_output_file_path, 'a') { |f|
		f.puts(text)
	}
end

def puts_section_to_formatted_output(section_text)
	open($formatted_output_file_path, 'a') { |f|
		f.puts
		f.puts(text)
		f.puts
	}
end

puts_section_to_formatted_output('# Amazon S3 Deploy')

def cleanup_before_error_exit(reason_msg=nil)
	puts_section_to_formatted_output("## Failed")
	unless reason_msg.nil?
		puts_section_to_formatted_output(reason_msg)
	end
	puts_section_to_formatted_output("Check the Logs for details.")
end


status = "success"
begin
	# checks
	#
	# ipa
	unless File.exists?(options[:ipa])
		err_msg = "No IPA found to deploy. Terminating."
		puts err_msg
		cleanup_before_error_exit(err_msg)
		exit!
	end
	# access_key
	unless options[:access_key]
		err_msg = "No AWS access key provided. Terminating."
		puts err_msg
		cleanup_before_error_exit(err_msg)
		exit!
	end
	# secret_key
	unless options[:secret_key]
		err_msg = "No AWS secret key provided. Terminating."
		puts err_msg
		cleanup_before_error_exit(err_msg)
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
		utc_timestamp = Time.now.utc.to_i
		path = "#{utc_timestamp}_bitrise_#{options[:app_title]}_#{options[:app_slug]}/build_#{options[:build_slug]}/"
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
	email_ready_link_url = "itms-services://?action=download-manifest&url=#{public_url_plist}"
	File.open(File.join(ENV['HOME'], '.bash_profile'), 'a') { |f| f.write("export S3_DEPLOY_STEP_EMAIL_READY_URL=\"#{email_ready_link_url}\"\n") }

	puts_section_to_formatted_output("## Success")
	puts_string_to_formatted_output("* **IPA link**: [#{public_url_ipa}](#{public_url_ipa})")
	puts_string_to_formatted_output("* **DSYM link**: [#{public_url_dsym}](#{public_url_dsym})")
	puts_string_to_formatted_output("* **Plist link**: [#{public_url_plist}](#{public_url_plist})")
	puts_string_to_formatted_output("* **Install link** (open this link on an iOS device to install the app): [#{email_ready_link_url}](#{email_ready_link_url})")

rescue => ex
	err_msg = "Exception happened: #{ex}"
	puts err_msg
	status = "failed"
	cleanup_before_error_exit(err_msg)
	exit 1
ensure
	File.open(File.join(ENV['HOME'], '.bash_profile'), 'a') { |f| f.write("export S3_DEPLOY_STEP_STATUS=\"#{status}\"\n") }
	puts "status=" + status
end
