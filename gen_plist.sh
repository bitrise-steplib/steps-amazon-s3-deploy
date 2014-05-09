#!/bin/bash
# Generates an external xml plist with the minimum required entries from inner info.plist in ipa

unzip "$CONCRETE_IPA_PATH" > /dev/null
BUNDLEID="/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' ./Payload/$CONCRETE_APP_TITLE.app/Info.plist"
BUNDLEVER="/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' ./Payload/$CONCRETE_APP_TITLE.app/Info.plist"
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
					<string>$CONCRETE_IPA_PATH</string>
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
				<string>testtitle</string>
			</dict>
		</dict>
	</array>
</dict>
</plist>" > "$CONCRETE_APP_TITLE".plist

export S3_DEPLOY_PLIST_PATH="$CONCRETE_APP_TITLE".plist
cat "$CONCRETE_APP_TITLE".plist
