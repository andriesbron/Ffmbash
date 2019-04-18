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


#echo "WGET call:"
#content=$(wget http://localhost:8888/service.php -q -O -)
#echo $content


#! Initialize ffmpeg variables:
ff_vdev=""
ff_adev=""
ff_screen_resolution=650x360
ff_rootdir=videos
ff_command=apple_hls                    #! Default command to be used.
ff_autostart=0                          #! If 1 ffmpeg immediately starts when having prepared all settings
ff_fps=""
ff_set_duration=""
output_file=""
output_dir=$(date +%Y%m%dT%H%M%S)       #! Target directory of streams that target a file

#! Initialize ffmbash items
template_file=""
ff_remote_tpl=""

#! Initialize automation based on ics formats
ff_dtstart=""                           #! Start time of a livestream for automation purposes. Not yet working.
ff_dtend=""                             #! End time of a livestream for automation purposes. Not yet working, set ffmpeg streaming duration.
ff_rrule=false                          #! Start time of a livestream for automation purposes. Not yet working.
ff_wait_for_date=false

function show_help {
. modules/help.sh
}

while getopts "h?av:s:c:t:o:r:w" opt; do
    case "$opt" in
        h|\?)
        show_help
        exit 0
        ;;
        a)  autostart=1;;
        v)  ff_vdev=$OPTARG;;
        s)  ff_adev=$OPTARG;;
        c)  ff_command=$OPTARG;;
        t)  template_file=$OPTARG;;
        o)  output_file=$OPTARG;;
        r)  ff_fps=$OPTARG;;
        w)  ff_wait_for_date=true;;
    esac
done
shift $((OPTIND-1))
[ "${1:-}" = "--" ] && shift

#if a template file is given, read the template and parse it.
if [ ! -z $template_file ]; then
    SAVEIFS=IFS
    IFS="="
    while read -r name value
    do
        #! Due to lack of associative arrays:
        case "$name" in
            'AUTOSTART') ff_autostart=$value;;
            'ADEV') ff_adev=$value;;
            'VDEV') ff_vdev=$value;;
            'ADEVNAME') ff_adevname=$value;;
            'VDEVNAME') ff_vdevname=$value;;
            'REMOTETPL') ff_remote_tpl=$value;;

            'DTSTART') ff_dtstart=$value;;
            'DTEND') ff_dtend=$value;;
            'RRULE') ff_rrule=$value;;
            'WAITFORDTSTART')
            if [[ $value == "1" ]];then
                ff_wait_for_date=true
            fi
            ;;

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
            echo "${bold}Available video devices:${normal}"
        fi
        if [[ ${line} == *'AVFoundation audio devices:'* ]]; then
            echo ""
            echo "${bold}Available audio devices:${normal}"
        fi
        if [[ ${line} == *'AVFoundation input device'* ]]; then
            echo ${line}
        fi
    done
    IFS=SAVEIFS
    echo ""
    echo "${bold}Select the video device (number) you want to use (leave empty for none):${normal} "
    read ff_vdev
    echo "${bold}Select the audio device (number) you want to use (leave empty for none):${normal} "
    read ff_adev
    #! If no media device is selected, exit the script
    #! Works or [ ! -z $vdev ] means not empty.
    if [ -z $ff_adev ] && [ -z $ff_vdev ]; then
        echo "${bold}Sorry, you must select either or both a video or audio device, thank you for using ffmbash.${normal}"
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
            echo "${bold}"${ffmbashfpsin}" is not a proper framerate, select a proper framerate:${normal} "
        else
            echo "${bold}Default framerate is not a proper framerate, select a proper framerate:${normal} "
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


#! Run ICS module
. modules/ics.sh
if [ ! -z $ff_dtstart ] && [ ! -z $ff_dtend ]; then 
echo "Running ics"
    ics_run $ff_dtstart $ff_dtend $ff_rrule $ff_wait_for_date  
    #! If livenow, set the stream duration so that it automatically stops
    if [ $ICS_P_LIVENOW = true ]; then
        ff_set_duration="-t "$ICS_P_DURATION
        ff_autostart=1
    else
        echo ""
        echo "DTSTART event did not yet happen. If you want me to wait for it, set -w option or set WAITFORDTSTART=1 in template. "
        echo ""
        exit 0
    fi
fi

#! Creating target directory and load the ffmpeg command
mkdir -p  "$ff_rootdir/$output_dir"

if [ -z $ff_command ]; then
    echo "Enter ffmpeg command to use (name of file without extension in the command directory):"
    read ff_command
fi
. commands/"$ff_command".sh


echo ""
echo "${bold}Ffmbash session settings${normal}"
echo "Video device     : "$ff_vdev
echo "Audio device     : "$ff_adev
echo "Screen resolution: "$ff_screen_resolution
echo "Framerate        : "${ffmbashfpsin}
echo "ffmpeg command   : "${ff_command}
echo "${bold}Automated start${normal}"
#! ICS support only through use of a template
if [ ! -z $template_file ]; then
    echo "Start time       : "$ff_dtstart
    echo "End time         : "$ff_dtend
    echo "Rrule (not yet available): "$ff_rrule
    echo "Start Live Now   : "$ICS_P_LIVENOW
    #! If livenow, set the stream duration so that it automatically stops
    #! Variable is set before command is loaded :-)
    if [ $ICS_P_LIVENOW = true ]; then
        echo "Program duration : "$ICS_P_DURATION
    fi
else
    echo "Start time       : Cannot be used command line (use template)."
fi
echo "${bold}Ffmpeg command:${normal}"
echo $COMMAND
echo ""
if [ $ff_autostart -eq 0 ]; then
    echo "Press <enter> to starting streaming. Once started, press enter <q> to quit."
    read startstreaming
fi

eval $COMMAND
