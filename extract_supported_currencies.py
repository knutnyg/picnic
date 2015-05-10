#!/usr/bin/env python
import json
import urllib2
import plistlib
import sys

pl = plistlib.readPlist("../picnic/config.plist")
try:
	t = urllib2.urlopen(pl['api_url'] + "currencies").read()
	json1_data = json.loads(t)

except urllib2.HTTPError:
	print "Error accessing API"
	sys.exit(1)

f = open('supported_currencies.txt','w+')

for VAL in json1_data:
	f.write(VAL + '\n')

f.close()





