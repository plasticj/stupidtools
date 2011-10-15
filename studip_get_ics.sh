#!/bin/bash

## Options
## i'm tempted to s/STUDIP/STUPID/
STUDIP_USER=''
STUDIP_PASSWD=''
ICS_OUTPUT="studip.ics"


## curl options
CURLOPT="-s" ##stfu

## URLs
CALENDAR_URL="https://e-learning.tu-harburg.de/studip/calendar.php?cmd=export"
LOGIN_URL="https://e-learning.tu-harburg.de/studip/index.php?again=yes"

## temp files
COOKIEJAR="/tmp/studip.cookie"
OUTPUT="/tmp/out.curl"

function urlencode() {
	perl -MURI::Escape -e "print uri_escape('$1');"
}

STUDIP_USER=$(urlencode "$STUDIP_USER")
STUDIP_PASSWD=$(urlencode "$STUDIP_PASSWD")

## get login front page to grep security token and get session cookie
curl $CURLOPT -c "$COOKIEJAR" -i -o "$OUTPUT" $LOGIN_URL

## extract tokens
SEC_TOKEN=$(grep -o 'security_token" value="[^"]*"' "$OUTPUT" | cut -d '"' -f 3)
LOGIN_TICKET=$(grep -o 'login_ticket" value="[^"]*"' "$OUTPUT" | cut -d '"' -f 3)
#echo "sec_token:" $SEC_TOKEN
#echo "login_ticket:" $LOGIN_TICKET

## do we need this? idk,lol
SEC_TOKEN=$(urlencode "$SEC_TOKEN")
LOGIN_TICKET=$(urlencode "$LOGIN_TICKET")

## assemble POST data, don't know if everything is needed
POSTDATA="security_token=$SEC_TOKEN&login_ticket=$LOGIN_TICKET&resolution=1280x800&loginname=$STUDIP_USER&password=$STUDIP_PASSWD&login.x=50&login.y=8"

## now do login
curl $CURLOPT -i -o "$OUTPUT" -b "$COOKIEJAR" -c "$COOKIEJAR" -d"$POSTDATA" "$LOGIN_URL"

## now we get to request ics file (finally!)
## todo: let user input data range
POSTDATA="extype=ALL&experiod=all&exstartday=15&exstartmonth=10&exstartyear=2011&exendday=15&exendmonth=10&exendyear=2012&x=76&y=20&expmod=exp"

curl $CURLOPT -c "$COOKIEJAR" -b "$COOKIEJAR" -d "$POSTDATA" -i -o"$OUTPUT" "$CALENDAR_URL"
# see where our file is
LOC=$(grep "Location:" "$OUTPUT" | cut -d " " -f 2)
## download ics file
curl $CURLOPT -c "$COOKIEJAR" -b "$COOKIEJAR" -i -o "$ICS_OUTPUT" "$LOC"

if [ -f "$ICS_OUTPUT" ]; then
	echo ".ics file downloaded to $ICS_OUTPUT"
else
	echo "something went wrong, lol."
fi
## cleanup
rm -f "$COOKIEJAR"
rm -f "$OUTPUT"
