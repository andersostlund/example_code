#!/bin/bash
#
# This script interfaces a TTS service (available via MQTT)
# If the phrase to speak already is cashed it uses that instead.
#

# Local say function
lsay() {
    # Create md5 from phrase.
    fid=`echo "$1" | md5sum | cut -f1 -d" "`

    #  Create (base)filename
    fid=`echo "md5_${fid}"`

    # Local file name for this wav
    wavfname=/home/pi/soundlib/sv/$fid.wav

    # Check file storage if it is already spoked (file exists) or has to be requested.
    if [ ! -e $wavfname ] 
    then
       # Ask my tts service to crate a file. Will be spoken deferred when wav-file arrives
       /usr/bin/mosquitto_pub -h mqttbroker  -t "someName/home/services/tts" -m "$fid:$1"
    else
       # File with phrase already found. Plays it.
       /usr/bin/mplayer -ao alsa -noconsolecontrols $wavfname &>/dev/null
    fi
}

 
INPUT=$*

# Clean up text phrase and create unicode.
encodedTxt=`echo $INPUT | xxd -plain | tr -d '\n' | sed 's/\(..\)/%\1/g'`

# Speak (or fetch) phrase.
lsay $encodedTxt

