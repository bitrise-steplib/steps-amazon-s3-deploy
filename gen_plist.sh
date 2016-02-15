#!/bin/bash
# Generates an xml structured plist with the minimum required entries from inner info.plist in ipa

unzip "$ipa_path" > /dev/null

last_find_app_path=""
find_apps_count=0
find_apps_output="$(find . -path "./Payload/*.app" -maxdepth 2 -mindepth 2)"
if [[ "${find_apps_output}" != "" ]] ; then
	while IFS= read -r app
	do
	find_apps_count=$(($find_apps_count + 1))
	last_find_app_path=$app
	done <<< "${find_apps_output}"
fi

if [ "$find_apps_count" -eq 0 ] ; then
	echo "No .app found in ipa"
	exit 1
fi

if [ "$find_apps_count" -gt 1 ] ; then
	echo "$find_apps_count .app found in ipa"
	exit 1
fi

APP_BASE_NAME=${last_find_app_path##*/}
APP_NAME=${APP_BASE_NAME%.app}

BUNDLEID=`/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" ./Payload/"$APP_BASE_NAME"/Info.plist`
BUNDLEVER=`/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" ./Payload/"$APP_BASE_NAME"/Info.plist`

generated_plist_path="./Info.plist"
if [ -e "${generated_plist_path}" ]; then
	rm "${generated_plist_path}"
fi

echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
	<key>items</key>
	<array>
		<dict>
			<key>assets</key>
			<array>
				<dict>
					<key>kind</key>
					<string>software-package</string>
					<key>url</key>
					<string>$S3_DEPLOY_STEP_URL_IPA</string>
				</dict>
			</array>
			<key>metadata</key>
			<dict>
				<key>bundle-identifier</key>
				<string>$BUNDLEID</string>
				<key>bundle-version</key>
				<string>$BUNDLEVER</string>
				<key>kind</key>
				<string>software</string>
				<key>title</key>
				<string>$APP_NAME</string>
			</dict>
		</dict>
	</array>
</dict>
</plist>" > "${generated_plist_path}"

rm -rf ./Payload
