cd ..
git pull

#Update app version
appVersion=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "picnic/Info.plist")
appVersion=$(($appVersion + 0.1))

echo Setting app version to $appVersion
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $appVersion" picnic/Info.plist

#Reset build number
echo Setting buildnumber to 0
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion 0" picnic/Info.plist