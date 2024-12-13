#!/bin/bash

set_profile () {
	echo "Setting active profile to $1"
	gdbus call --system --dest net.hadess.PowerProfiles --object-path /net/hadess/PowerProfiles --method org.freedesktop.DBus.Properties.Set 'net.hadess.PowerProfiles' 'ActiveProfile' "<'$1'>" > /dev/null
	[[ $? -ne 0 ]] && echo "Could not change power level!"
}

gdbus monitor --system --dest org.freedesktop.UPower --object-path /org/freedesktop/UPower | while read LINE; do
#	act_profile=$(gdbus call --system --dest net.hadess.PowerProfiles --object-path /net/hadess/PowerProfiles --method org.freedesktop.DBus.Properties.Get 'net.hadess.PowerProfiles' 'ActiveProfile' | awk -F "[<'>]" '{ print $3 }')
#	batt_state=$(gdbus call --system --dest org.freedesktop.UPower --object-path /org/freedesktop/UPower --method org.freedesktop.DBus.Properties.Get 'org.freedesktop.UPower' 'OnBattery' | awk -F "[<>]" '{ print $2 }')
#	echo $act_profile $batt_state
	batt_state=$(echo $LINE | awk -F "[<>]" '{ print $2 }')
	if [ "$batt_state" = "true" ]; then
		echo "On battery power" && set_profile balanced
	elif [ "$batt_state" = "false" ]; then
		echo "On AC power" && set_profile performance
	else
		echo "Unknown battery state found!"
	fi
done
