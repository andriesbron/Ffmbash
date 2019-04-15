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
bold=$(tput bold)
normal=$(tput sgr0)


echo "WGET call:"
content=$(wget http://localhost:8888/service.php -q -O -)
echo $content


# Initialize variables:
ff_screen_resolution=650x360
ff_rootdir=videos
ff_command=apple_hls                    #! Default command to be used.
ff_autostart=0                          #! If 1 ffmpeg immediately starts when having prepared all settings
ff_dtstart=""                           #! Start time of a livestream for automation purposes. Not yet working.
ff_dtend=""                             #! End time of a livestream for automation purposes. Not yet working, set ffmpeg streaming duration.
ff_rrule=""                             #! Start time of a livestream for automation purposes. Not yet working.
output_file=""
output_dir=$(date +%Y%m%dT%H%M%S)       #! Target directory of streams that target a file
verbose=0
template_file=""
ff_fps=""

#! Future use, check an ics file if the I should go live now, to automate camera's.
. modules/ics.sh
POINTER_LIVENOW=false
parseics http://localhost:8888/livestream.ics
echo "$POINTER_LIVENOW"


function show_help {
. modules/help.sh
}

while getopts "h?avc:t:o:r:" opt; do
    case "$opt" in
        h|\?)
        show_help
        exit 0
        ;;
        a)  autostart=1;;
        v)  verbose=1;;
        c)  ff_command=$OPTARG;;
        t)  template_file=$OPTARG;;
        o)  output_file=$OPTARG;;
        r)  ff_fps=$OPTARG;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

echo "autostart=$autostart, verbose=$verbose, template_file='$template_file', output_file='$output_file', ff_fps=$ff_fps, Leftovers: $@"

#if a template file is given, read the template and start if autostart is set.
if [ ! -z $template_file ]; then
    SAVEIFS=IFS
    IFS="="
    while read -r name value
    do
        #echo "Content of $name is ${value//\"/}"
        #! Due to lack of associative arrays:
        case "$name" in
            'AUTOSTART') ff_autostart=$value;;
            'ADEV') ff_adev=$value;;
            'VDEV') ff_vdev=$value;;
            'ADEVNAME') ff_adevname=$value;;
            'VDEVNAME') ff_vdevname=$value;;
            'DTSTART') ff_dtstart=$value;;
            'DTSTOP') ff_dtstop=$value;;
            'FPSIN') ff_fps=$value;;
            'COMMAND') ff_command=$value;;
            'SCREENRES') ff_screen_resolution=$value;;
            
            'RTSP_USER_NAME') ff_rtsp_user_name=$value;;
            'RTSP_USER_PASSWORD') ff_rtsp_user_password=$value;;
            'RTSP_SERVER_URL') ff_rtsp_server_url=$value;;
            'RTSP_SERVER_PORT') ff_rtsp_server_port=$value;;
            'RTSP_KEY') ff_rtsp_key=$value;;
            
            *);;
        esac
    done < templates/$template_file.txt
    IFS=SAVEIFS
fi
#! Setting the devices
if [ -z $ff_adev ] && [ -z $ff_vdev ]; then
    echo ""
    echo "Set your media devices for livestreaming:"
    echo ""
    autostart=false
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
            echo ${line}
        fi
    done
    IFS=SAVEIFS
    echo ""
    echo "Select the video device (number) you want to use (leave empty for none):"
    read ff_vdev
    echo "Select the audio device (number) you want to use (leave empty for none):"
    read ff_adev
    #! If no media device is selected, exit the script
    #! Works or [ ! -z $vdev ] means not empty.
    if [ -z $ff_adev ] && [ -z $ff_vdev ]; then
        echo "Sorry, you must select either or both a video or audio device, thank you for using ffmbash."
        echo ""
        echo ""
        exit 0
    fi
fi

#! @todo ffmbashfpsin should be set later, instead, handle ff_fps here, e.g. ff_fps=${npart}.
#! Setting the framerate
if [[ ${ff_fps} == "" ]]; then
    ffmbashfpsin=""
else
    ffmbashfpsin="-framerate ${ff_fps}"
fi
if [ -z $ffmbashfpsin ]; then
    #! If the framerate is not set then a check is performed if the default framerate is working.
    SAVEIFS=IFS
    IFS=$'\n'
    echo ""
    echo "Trying stream for 1 second, one moment please..."
    
    i=0
    fpsok=true
    for line in $(ffmpeg -y -f avfoundation -i "${ff_vdev}:${ff_adev}" -c:v libx264 -crf 0 -preset ultrafast -t 00:00:00.100 null 2>&1); do
        if [[ ${line} == *"is not supported by the device"* ]]; then
            fpsok=false
        fi
        if [[ ${line} == *']fps'* ]]; then
            framerate+=(${line})
            echo ${i}": "${line}
            ((i++))
        fi
    done
    
    if [ "$fpsok" = false ]; then
        echo ""
        if [ ! -z $ffmbashfpsin ]; then
            echo ${ffmbashfpsin} "is not a proper framerate, select a proper framerate:"
        else
            echo "Default framerate is not a proper framerate, select a proper framerate:"
        fi
        read myframerate
        IFS=$'   '
        for part in ${framerate[$myframerate]}; do
            if [[ ${part} == *"fps"* ]]; then
                IFS=$'.'
                counter=0
                for npart in ${part}; do
                    if [ $counter -eq 0 ]; then
                        ffmbashfpsin="-framerate ${npart}"
                    fi
                    counter=$((counter+1))
                done
            fi
        done
    fi
    IFS=SAVEIFS
fi
if [ -z $ff_command ]; then
    echo "Enter ffmpeg command to use (name of file without extension in the command directory):"
    read ff_command
fi
#! Creating target directory and load the ffmpeg command
mkdir -p  "$ff_rootdir/$output_dir"
. commands/"$ff_command".sh


echo ""
echo "${bold}Settings${normal}"
echo "Video device     : "$ff_vdev
echo "Audio device     : "$ff_adev
echo "Screen resolution: "$ff_screen_resolution
echo "Framerate        : "${ffmbashfpsin}
echo "ffmpeg command   : "${ff_command}
echo "${bold}Automated start${normal}"
echo "Start time       : "$ff_dtstart
echo "End time         : "$ff_dtend
echo "Rrule            : "$ff_rrule
echo "Running following ffmpeg command:"
echo ""
echo $COMMAND
echo ""

if [ $ff_autostart -eq 0 ]; then
    echo "Press <enter> to starting streaming. Once started, press enter <q> to quit."
    read startstreaming
fi

eval $COMMAND

