#

options = {
	ipa: ENV['BITRISE_IPA_PATH'],
	dsym: ENV['BITRISE_DSYM_PATH'],
	app_slug: ENV['BITRISE_APP_SLUG'],
	build_slug: ENV['BITRISE_BUILD_SLUG'],
	access_key: ENV['S3_DEPLOY_AWS_ACCESS_KEY'],
	secret_key: ENV['S3_DEPLOY_AWS_SECRET_KEY'],
	bucket_name: ENV['S3_BUCKET_NAME'],
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
		f.puts(section_text)
		f.puts
	}
end

puts_section_to_formatted_output('# Amazon S3 Deploy')

def cleanup_before_error_exit(reason_msg=nil)
	puts " [!] Error: #{reason_msg}"
	puts_section_to_formatted_output("## Failed")
	unless reason_msg.nil?
		puts_section_to_formatted_output(reason_msg)
	end
	puts_section_to_formatted_output("Check the Logs for details.")
end

def s3_object_uri_for_bucket_and_path(bucket_name, path_in_bucket)
	return "s3://#{bucket_name}/#{path_in_bucket}"
end

def public_url_for_bucket_and_path(bucket_name, path_in_bucket)
	return "https://#{bucket_name}.s3.amazonaws.com/#{path_in_bucket}"
end


$s3cmd_config_path = "s3cfg.config"
def do_s3cmd(command_str)
	return system(%Q{s3cmd -c "#{$s3cmd_config_path}" #{command_str}})
end

status = "success"
begin
	# checks
	#
	# ipa
	raise "No IPA found to deploy. Terminating." unless File.exists?(options[:ipa])
	# dsym
	unless File.exists?(options[:dsym])
		options[:dsym] = nil
		puts_section_to_formatted_output "DSYM file not found. To generate debug symbols (dSYM) go to your Xcode Project's Settings - Build Settings - Debug Information Format and set it to DWARF with dSYM File."
	end
	# access_key
	raise "No AWS access key provided. Terminating." unless options[:access_key]
	# secret_key
	raise "No AWS secret key provided. Terminating." unless options[:secret_key]

	# Install s3cmd
	puts " (i) Checking s3cmd"
	if system("s3cmd --version")
		puts " (i) s3cmd already installed"
	else
		puts " (i) installing s3cmd"
		raise "Failed to install s3cmd" unless system("brew install s3cmd")
		raise "Failed to get s3cmd version after install" unless system("s3cmd --version")
	end
	
	# AWS configs
	raise "Failed to set access keys" unless system(%Q{printf %"s\n" '[default]' "access_key = #{options[:access_key]}" "secret_key = #{options[:secret_key]}" > #{$s3cmd_config_path}})

	# define object path
	base_path_in_bucket = ""
	if options[:path_in_bucket]
		base_path_in_bucket = options[:path_in_bucket]
	else
		utc_timestamp = Time.now.utc.to_i
		base_path_in_bucket = "bitrise_#{options[:app_slug]}/#{utc_timestamp}_build_#{options[:build_slug]}"
	end

	puts " (i) Base path in Bucket: #{base_path_in_bucket}"

	# supported: private, public_read
	acl_arg = '--acl-public'
	if (options[:acl])
		case options[:acl]
		when 'public_read'
			acl_arg = '--acl-public'
		when 'private'
			acl_arg = '--acl-private'
		else
			raise "Invalid ACL option: #{options[:acl]}"
		end
	end

	# ipa upload
	puts_section_to_formatted_output "## Uploading IPA"
	ipa_path_in_bucket = "#{base_path_in_bucket}/#{File.basename(options[:ipa])}"
	ipa_full_s3_path = s3_object_uri_for_bucket_and_path(options[:bucket_name], ipa_path_in_bucket)
	public_url_ipa = public_url_for_bucket_and_path(options[:bucket_name], ipa_path_in_bucket)
	#
	raise "Failed to upload IPA" unless do_s3cmd(%Q{put "#{options[:ipa]}" "#{ipa_full_s3_path}"})
	raise "Failed to set IPA ACL" unless do_s3cmd(%Q{setacl "#{ipa_full_s3_path}" #{acl_arg}})
	File.open(File.join(ENV['HOME'], '.bash_profile'), 'a') { |f| f.write("export S3_DEPLOY_STEP_URL_IPA=\"#{public_url_ipa}\"\n") }
	puts_section_to_formatted_output "* IPA uploaded: `#{public_url_ipa}`"

	# dsym upload
	if options[:dsym]
		puts_section_to_formatted_output "## Uploading dSYM"
		dsym_path_in_bucket = "#{base_path_in_bucket}/#{File.basename(options[:dsym])}"
		dsym_full_s3_path = s3_object_uri_for_bucket_and_path(options[:bucket_name], dsym_path_in_bucket)
		public_url_dsym = public_url_for_bucket_and_path(options[:bucket_name], dsym_path_in_bucket)
		#
		raise "Failed to upload dSYM" unless do_s3cmd(%Q{put "#{options[:dsym]}" "#{dsym_full_s3_path}"})
		raise "Failed to set dSYM ACL" unless do_s3cmd(%Q{setacl "#{dsym_full_s3_path}" #{acl_arg}})

		File.open(File.join(ENV['HOME'], '.bash_profile'), 'a') { |f| f.write("export S3_DEPLOY_STEP_URL_DSYM=\"#{public_url_dsym}\"\n") }
		puts_section_to_formatted_output "* dSYM uploaded: `#{public_url_dsym}`"
	end

	ENV['S3_DEPLOY_STEP_URL_IPA'] = "#{public_url_ipa}"

	# plist generation - we have to run it after we have obtained the public url to the ipa
	system("sh ./gen_plist.sh")

	# plist upload
	plist_local_path = "Info.plist"

	if File.exists?(plist_local_path)
		plist_path_in_bucket = "#{base_path_in_bucket}/Info.plist"
		plist_full_s3_path="s3://#{options[:bucket_name]}/#{plist_path_in_bucket}"
		public_url_plist = public_url_for_bucket_and_path(options[:bucket_name], plist_path_in_bucket)
		#
		raise "Failed to upload IPA" unless do_s3cmd(%Q{put "#{plist_local_path}" "#{plist_full_s3_path}"})
		raise "Failed to set Plist ACL" unless do_s3cmd(%Q{setacl "#{plist_full_s3_path}" #{acl_arg}})
		raise "Failed to remove Plist" unless system(%Q{rm "#{plist_local_path}"})
	else
		puts "NO PLIST :<"
	end

	File.open(File.join(ENV['HOME'], '.bash_profile'), 'a') { |f| f.write("export S3_DEPLOY_STEP_URL_PLIST=\"#{public_url_plist}\"\n") }
	email_ready_link_url = "itms-services://?action=download-manifest&url=#{public_url_plist}"
	File.open(File.join(ENV['HOME'], '.bash_profile'), 'a') { |f| f.write("export S3_DEPLOY_STEP_EMAIL_READY_URL=\"#{email_ready_link_url}\"\n") }

	puts_section_to_formatted_output("## Success")
	#
	puts_section_to_formatted_output("### File Access Level")
	puts_section_to_formatted_output("Specified File Access Level: **#{options[:acl]}**")
	#
	puts_section_to_formatted_output("### IPA")
	puts_section_to_formatted_output("[link](#{public_url_ipa})")
	puts_section_to_formatted_output("Raw:")
	puts_section_to_formatted_output("    #{public_url_ipa}")
	#
	puts_section_to_formatted_output("### DSYM")
	if options[:dsym]
		puts_section_to_formatted_output("[link](#{public_url_dsym})")
		puts_section_to_formatted_output("Raw:")
		puts_section_to_formatted_output("    #{public_url_dsym}")
	else
		puts_section_to_formatted_output %Q{DSYM file not found.
			To generate debug symbols (dSYM) go to your
			Xcode Project's Settings - `Build Settings - Debug Information Format`
			and set it to **DWARF with dSYM File**.}
	end
	#
	puts_section_to_formatted_output("### Plist")
	puts_section_to_formatted_output("[link](#{public_url_plist})")
	puts_section_to_formatted_output("Raw:")
	puts_section_to_formatted_output("    #{public_url_plist}")
	#
	puts_section_to_formatted_output("### Install link")
	puts_section_to_formatted_output("**open this link on an iOS device to install the app**")
	puts_section_to_formatted_output(%Q{<a href="#{email_ready_link_url}" target="_blank">link</a>})
	puts_section_to_formatted_output("Raw:")
	puts_section_to_formatted_output("    #{email_ready_link_url}")

rescue => ex
	status = "failed"
	cleanup_before_error_exit("#{ex}")
	exit 1
ensure
	File.open(File.join(ENV['HOME'], '.bash_profile'), 'a') { |f| f.write("export S3_DEPLOY_STEP_STATUS=\"#{status}\"\n") }
	puts "status=" + status
	system("rm #{$s3cmd_config_path}")
end
