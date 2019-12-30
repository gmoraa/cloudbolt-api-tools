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

#Start the ssh validation process
null='/dev/null'
dwn_total=0
dwn_servers=()

for i in `$PWD/cloudbolt_list.sh $1 $2`
do
	echo -e '\x1dclose\x0d' | telnet $i 22 > $null 2> $null
	if [ $? -ne 0 ]
	then
		echo $i
		((dwn_total=dwn_total+1))
		dwn_servers+=($i)
	fi
done

if [ $dwn_total -gt 0 ]
then
	printf '%s\n' "${dwn_servers[@]}"
fi