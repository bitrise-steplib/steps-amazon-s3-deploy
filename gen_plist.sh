#!/bin/bash
# Generates an xml structured plist with the minimum required entries from inner info.plist in ipa

unzip "$BITRISE_IPA_PATH" > /dev/null

BASE_NAME=${BITRISE_IPA_PATH##*/}
APP_NAME=${BASE_NAME%.*}

BUNDLEID=`/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" ./Payload/"$APP_NAME".app/Info.plist`
BUNDLEVER=`/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" ./Payload/"$APP_NAME".app/Info.plist`

generated_plist_path="${BITRISE_APP_TITLE}.plist"
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
