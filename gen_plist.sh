#!/bin/bash
# Generates an xml structured plist with the minimum required entries from inner info.plist in ipa

unzip "$CONCRETE_IPA_PATH" > /dev/null

BUNDLEID=`/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" ./Payload/"$CONCRETE_APP_TITLE".app/Info.plist`
BUNDLEVER=`/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" ./Payload/"$CONCRETE_APP_TITLE".app/Info.plist`

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
				<string>$CONCRETE_APP_TITLE</string>
			</dict>
		</dict>
	</array>
</dict>
</plist>" > "$CONCRETE_APP_TITLE".plist
