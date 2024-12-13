#!/bin/bash
#	act_profile=$(gdbus call --system --dest net.hadess.PowerProfiles --object-path /net/hadess/PowerProfiles --method org.freedesktop.DBus.Properties.Get 'net.hadess.PowerProfiles' 'ActiveProfile' | awk -F "[<'>]" '{ print $3 }')
#	batt_state=$(gdbus call --system --dest org.freedesktop.UPower --object-path /org/freedesktop/UPower --method org.freedesktop.DBus.Properties.Get 'org.freedesktop.UPower' 'OnBattery' | awk -F "[<>]" '{ print $2 }')
#	echo $act_profile $batt_state

set_profile () {
	echo "Setting active profile to $1"
	gdbus call --system --dest net.hadess.PowerProfiles --object-path /net/hadess/PowerProfiles --method org.freedesktop.DBus.Properties.Set 'net.hadess.PowerProfiles' 'ActiveProfile' "<'$1'>" > /dev/null
	[[ $? -ne 0 ]] && echo "Could not change power level!"
}
check_state () {
	if [[ ! -z "$1" ]]; then 
	if [ "$1" = "true" ]; then
		echo "On battery power" && set_profile balanced
	elif [ "$1" = "false" ]; then
		echo "On AC power" && set_profile performance
	else
		echo "Unknown battery state found!"
	fi
	fi
}

start_state=$(gdbus call --system --dest org.freedesktop.UPower --object-path /org/freedesktop/UPower --method org.freedesktop.DBus.Properties.Get 'org.freedesktop.UPower' 'OnBattery' | awk -F "[<>]" '{ print $2 }')
check_state $start_state

gdbus monitor --system --dest org.freedesktop.UPower --object-path /org/freedesktop/UPower | while read LINE; do
	batt_state=$(echo $LINE | awk -F "[<>]" '{ print $2 }')
	check_state $batt_state
done
