#!/bin/bash

#Starts the silent validation process
if [[ $# -ne 2 ]]
then
	echo "Usage: echo.sh <http(s)://example.cloudbolt.com> </credentials/path/file.json>"
	exit 10
fi

regex='(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
if [[ ! $1 =~ $regex ]]
then
	echo "Invalid URL $1. Exiting."
	exit 20
fi

curl $1 -k &> /dev/null

if [[ $? -ne 0 ]]
then
	echo "Unable to reach $1. Exiting."
	exit 21 
fi

if [ ! -f "$2" ]
then
	echo "File does not exist or can be reached."
	exit 30
fi

cat $2 | python -mjson.tool &> /dev/null

if [[ $? -ne 0 ]]
then
	echo "Invalid file format $2. Exiting."
	exit 31
fi

#Start the listing process
export token=`curl -s -d "@$2" -H "Content-Type: application/json" -X POST "$1"/api/v2/api-token-auth/ -k | cut -d \" -f 4`
export pages=`curl -s -H 'Accept: application/json' -H "Authorization: Bearer $token" "$1"/api/v2/servers/?page_size=999 -k | python -mjson.tool | grep -i "list of servers" | awk '{print $9}' | tr -dc '0-9'`
export total=`curl -s -H 'Accept: application/json' -H "Authorization: Bearer $token" "$1"/api/v2/servers/?page_size=999 -k | python -mjson.tool | grep -i "total" | tr -dc '0-9'`
success=0
failures=0
servers=()

for  (( i=1; i<=$pages; i++ ))
do
	servers+=(`curl -s -H 'Accept: application/json' -H "Authorization: Bearer $token" "$1/api/v2/servers/?page=$i&page_size=999" -k | python -mjson.tool | grep -v "page" | grep -i href | cut -d / -f 5`)
done

for (( x=0; x<$total; x++ ))
do
	status=`curl -s -H 'Accept: application/json' -H "Authorization: Bearer $token" "$1/api/v2/servers/${servers[$x]}/" -k | python -mjson.tool | grep "POWEROFF\|hostname\|status"`
	echo $status | grep "POWEROFF" | grep "ACTIVE" | awk '{print($2)}' | tr -d ',"'

	if (( $SECONDS % 30 == 0  ))
	then
		export token=`curl -s -d "@$2" -H "Content-Type: application/json" -X POST "$1/api/v2/api-token-auth/" -k | cut -d \" -f 4`
	fi
done
