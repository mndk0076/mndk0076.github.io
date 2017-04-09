#!/bin/bash

# BLink PCB L.E.D. upon scanning
#	gcc -Wall -o greenLight greenLight.c -lwiringPi
#	sudo ./greenLight

# Server Connection
HOST='*********'
USER='*********'
PASSWD='*******'
FILE='entry.csv'

# Vars
datamtx=''

# Current Working directory to var
cwd=$(pwd)

# tmp data-matrix holder
tmp="$cwd/zbartmp"

# Name of scan results file
ScanResult="$cwd/entry.csv"

# Name of temp file
Temp="$cwd/tmp.txt"

function scan()
{
	rm $ScanResult
	rm $Temp
	clear

	zbarcam --raw --prescale=320x240 /dev/video0 > $tmp &

	# Last job running in background eg. zbarcam
	pid=$!

	# Sleep loop until $tmp file has content
	while [[ ! -s $tmp ]]
	do
		sleep 1
		# cleanup - add a trap that will remove $tmp and kill zbarcam
		# if any of the signals - SIGHUP SIGINT SIGTERM it received.
   		trap "rm -f $tmp; kill -s 9 $pid; exit" SIGHUP SIGINT SIGTERM
  	done

	# Kill tasks, free up space and call test.py to blink L.E.D.
	kill -s 9 $pid
	
	#	python test.py

	datamtx=$(cat $tmp)
	rm -f $tmp

	# Append scan results to file
	echo $datamtx >> $ScanResult
	LastScanned=`cat $ScanResult`

	# Search for appointments
	clear
	echo -e "\nSearching for appointments for" $LastScanned "..."

	ftp -n $HOST <<END_SCRIPT
	quote USER $USER
	quote PASS $PASSWD
	put $FILE
	quit
END_SCRIPT

	curl www.***********/***.php -# -o $Temp | tail -n 1
	echo ""

	# Fetch results from the server
	Result=`awk '{print $1}' $Temp | tail -n 1`
	while :
	do
  	if [ "$Result" == "Success!" ]||[ "$Result" == "Denied!" ];
	then
		cat $Temp | tail -n 1
		sleep 5
		echo -e "\n\nAuto-refreshing in 10 seconds" 
		sleep 8
		scan
	else echo -e "\nError estashblishing connection with the server."
		exit
	fi

	done
	exit
}

# Call the scan function
scan
