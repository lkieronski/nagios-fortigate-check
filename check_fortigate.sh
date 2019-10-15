#!/bin/bash

function usage {
	echo "USAGE"
	exit 3
}

function syscpu {

	local cpu=$(snmpget $scommand .1.3.6.1.4.1.12356.101.4.1.3.0 | awk {'print $4'})
	
	if [ $cpu -lt $warning ]; then
		echo "CPU usage: ${cpu}%"
		exit 0
	elif [ $cpu -lt $critical ]; then
		echo "*WARNING* CPU usage: ${cpu}%"
		exit 1
	else
		echo "***CRITICAL*** CPU usage: ${cpu}%"
		exit 2
	fi

}

function sysmemory {

	local percusage=$(snmpget $scommand .1.3.6.1.4.1.12356.101.4.1.4.0 | awk {'print $4'})
	
	if [ $percusage -lt $warning ]; then
		echo "Memory usage: ${percusage}%"
		exit 0
	elif [ $percusage -lt $critical ]; then
		echo "*WARNING* Memory usage: ${percusage}%"
		exit 1
	else
		echo "***CRITICAL*** Memory usage: ${percusage}%"
		exit 2
	fi

}

function sysuptime {

	local hour=3600
	local day=86400
	local minute=60
	local uptime=$(($(snmpget $scommand .1.3.6.1.4.1.12356.101.4.1.20.0| awk {'print $4'})/100))
	local D=$(($uptime/$day))
  	local H=$(($uptime/$hour%24))
  	local M=$(($uptime/$minute%60))
  	local S=$(($uptime%60))
	
	if [ $uptime -ge $day ]; then
		echo "Uptime: ${D}day(s) ${H}hour(s) ${M}minute(s) ${S}second(s)" 
		exit 0
	elif [ $uptime -ge $hour ]; then
		echo "*WARNING* Uptime: ${H}hour(s) ${M}minute(s) ${S}second(s)"
		exit 1
	else
		echo "***CRITICAL*** Uptime: ${M}minute(s) ${S}second(s)"
		exit 2
	fi
}

function syssessions {

	local sessions=$(snmpget $scommand .1.3.6.1.4.1.12356.101.4.1.8.0 | awk {'print $4'})
	
	if [ $sessions -lt $warning ]; then
		echo "Active sessions: ${sessions}"
		exit 0
	elif [ $sessions -lt $critical ]; then
		echo "*WARNING* Active sessions: ${sessions}"
		exit 1
	else
		echo "***CRITICAL*** Active sessions: ${sessions}"
		exit 2
	fi

}

ip="127.0.0.1"
community="default"
task="cpuusage"
warning=40
critical=80


if [ $# -eq 0 ]; then
	usage;
fi

while getopts ':hH:C:t:w:c:u:' opt
do
	case $opt in

		h )
			usage
			;;
		H )
			ip=$OPTARG
			;;
		C )
			community=$OPTARG
			;;

		t )
			task=$OPTARG
			;;

		w )
			warning=$OPTARG
			;;

		c )
			critical=$OPTARG
			;;

		i )
			interface=$OPTARG
			;;
		u )
			units=$OPTARG
			;;
			
		\? )
			echo "Invalid option $OPTARG" 1>&2
			usage
			exit 3
			;;
		: )
			echo "Invalid Option: -$OPTARG requires an argument" 1>&2
			usage
			exit 3
			;;

	esac
done


scommand="-v 2c -c $community $ip"

case $task in

	cpu )
		syscpu
		;;
	
	memory )
		sysmemory
		;;
	
	uptime )
		sysuptime
		;;
	
	sessions )
		syssessions
		;;
esac
