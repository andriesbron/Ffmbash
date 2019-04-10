#!/usr/bin/env bash

echo "WGET call:"
content=$(wget http://localhost:8888/service.php -q -O -)
echo $content

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

if [ -z $adev ] && [ -z $vdev ] #! Works or [ ! -z $vdev ] means not empty.
then
    echo "Sorry, you must select either or both a video or audio device, thank you for using ffmbash."
    echo ""
    echo ""
    exit 0
fi

#! Next try a short recording locally to check if the chosen parameters fit.
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

setframerate=""
if [ "$fpsok" = false ]; then
    echo "Select a framerate:"
    read myframerate
    echo "${framerate[$myframerate]}"

    IFS=$'   '

    for part in ${framerate[$myframerate]}; do
        echo ${part}
        if [[ ${part} == *"fps"* ]]; then
            #! 30.000000]fps something like this
            IFS=$'.'
            counter=0
            for npart in ${part}; do
                if [ $counter -eq 0 ]; then
                    newframerate=${npart}
                fi
                counter=$((counter+1))
                echo ${npart}
            done
        fi
    done
    setframerate="-framerate  $newframerate"
fi
IFS=SAVEIFS



echo $setframerate
echo "I found framerate "$newframerate
echo ""
echo "Selected video device "$vdev", selected audio device "$adev"."
echo "Starting streaming, enter q to quit..."
#ffmpeg -y  -f avfoundation "-$setframerate" -i "${vdev}:${adev}" -c:v libx264 -crf 0 -preset ultrafast test.m3u8
ffmpeg -y  -f avfoundation -i "${vdev}:${adev}" -c:v libx264 -crf 0 -preset ultrafast test.m3u8

