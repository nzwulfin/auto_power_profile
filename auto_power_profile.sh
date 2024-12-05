#!/bin/bash

dbus-monitor --system "type='signal',path='/org/freedesktop/UPower/devices/battery_BAT0',member='PropertiesChanged'" | while read LINE; do
    echo ${LINE} | grep battery_BAT0 | grep -q PropertiesChanged
    if [ $? -eq 0 ]; then
        BATT_STAT=$(dbus-send --print-reply=literal --system --dest=org.freedesktop.UPower /org/freedesktop/UPower/devices/battery_BAT0 org.freedesktop.DBus.Properties.Get  string:org.freedesktop.UPower.Device string:State | awk '{ print $3; }')
        if [ $BATT_STAT -eq 1 ] || [ $BATT_STAT -eq 4 ]; then
            LEVEL=$(powerprofilesctl list | grep -q performance && echo "performance" || echo "balanced")
        elif [ $BATT_STAT -eq 5 ]; then
            LEVEL="balanced"
        else
            LEVEL="power-saver"
        fi
	echo "Changing power level to ${LEVEL}"
	gdbus call --system --dest net.hadess.PowerProfiles --object-path /net/hadess/PowerProfiles --method org.freedesktop.DBus.Properties.Set 'net.hadess.PowerProfiles' 'ActiveProfile' "<'${LEVEL}'>" > /dev/null
	[[ $? -ne 0 ]] && echo "Could not change power level to ${LEVEL}!"
    fi
done
