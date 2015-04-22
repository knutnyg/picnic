cd ..
git pull
buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "picnic/Info.plist")
buildNumber=$(($buildNumber + 1))
echo Incrementing buildnumber from $((buildNumber-1)) to $buildNumber
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" picnic/Info.plist

