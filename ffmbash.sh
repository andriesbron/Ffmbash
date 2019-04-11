#!/usr/bin/env bash

# Ffmbash is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# Ffmbash is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with Ffmbash.  If not, see <http://www.gnu.org/licenses/>.

echo "WGET call:"
content=$(wget http://localhost:8888/service.php -q -O -)
echo $content

#if a template file is given, read the template and start if autostart is set.
SAVEIFS=IFS
IFS="="
while read -r name value
do
    echo "Content of $name is ${value//\"/}"
done < templates/config.txt



echo ""
echo "Protocols"
echo "0 HLS"
echo "1 RTSP"
echo "Select broadcasting protocol (empty=HLS):"
#read protocol

echo ""
echo "Destiny"
echo "0 File"
echo "1 PUT method of server "
echo "Select destiny of stream (empty=File):"
#read streamdestiny

echo ""
echo "Set your media devices for livestreaming:"
echo ""

#! Display all available media device for selection:
SAVEIFS=IFS
IFS=$'\n'
for line in $(ffmpeg -f avfoundation -list_devices true -i “” 2>&1); do
    if [[ ${line} == *'AVFoundation video devices:'* ]]; then
        echo ""
        echo "--- Available video devices ---"
    fi
    if [[ ${line} == *'AVFoundation audio devices:'* ]]; then
        echo ""
        echo "--- Available audio devices ---"
    fi
    if [[ ${line} == *'AVFoundation input device'* ]]; then
        #! @todo Now parse the ${line} to save it as configuration, to start ffbash without selecting but directly start streaming.
        echo ${line}
    fi
done

echo ""
echo "Select the video device (number) you want to use (leave empty for none):"
read vdev
echo "Select the audio device (number) you want to use (leave empty for none):"
read adev

#! If no media device is selected, exit the script
if [ -z $adev ] && [ -z $vdev ] #! Works or [ ! -z $vdev ] means not empty.
then
    echo "Sorry, you must select either or both a video or audio device, thank you for using ffmbash."
    echo ""
    echo ""
    exit 0
fi

#! Launch ffmpeg and find out if the camera is starting instead of complaining about framerates

i=0
fpsok=true
echo ""
echo "Trying stream for 1 second, one moment please..."
#for line in $(ffmpeg -y -f avfoundation -i "${vdev}:${adev}" -c:v libx264 -crf 0 -preset ultrafast -t 00:00:00.100 test.m3u8 2>&1); do
for line in $(ffmpeg -y -f avfoundation -i "${vdev}:${adev}" -c:v libx264 -crf 0 -preset ultrafast -t 00:00:00.100 null 2>&1); do
    if [[ ${line} == *"is not supported by the device"* ]]; then
        fpsok=false
        echo ""
        echo "Ouch, need a framerate, select one of these available framerates:"
    fi
    if [[ ${line} == *']fps'* ]]; then
        framerate+=(${line})
        echo ${i}": "${line}
        ((i++))
    fi
done

#! Initially, don't set a framerate, if, however framerate issues, fpsok is false and the next commands obtains a proper framerate setting from the user.
setframerate=""
if [ "$fpsok" = false ]; then
    echo "Select a framerate:"
    read myframerate
    #! echo "${framerate[$myframerate]}"
    #! Perform some serious parsing...
    IFS=$'   '
    for part in ${framerate[$myframerate]}; do
        if [[ ${part} == *"fps"* ]]; then
            #! 30.000000]fps something like this
            IFS=$'.'
            counter=0
            for npart in ${part}; do
                if [ $counter -eq 0 ]; then
                    setframerate="-framerate ${npart}"
                fi
                counter=$((counter+1))
            done
        fi
    done
fi
IFS=SAVEIFS

echo ""
echo "Selected video device "$vdev", selected audio device "$adev"."
echo "Starting streaming, enter q to quit..."
echo 

#! @bug Command below does not work, it breaks its neck over ${setframerate} while "${vdev}:${adev}" works. Need to use eval.
#ffmpeg -y ${setframerate} -f avfoundation -i "${vdev}:${adev}" -c:v libx264 -crf 0 -preset ultrafast test.m3u8

command="ffmpeg -y ${setframerate} -f avfoundation -i \"${vdev}:${adev}\" -c:v libx264 -crf 0 -preset ultrafast test.m3u8"
eval $command
