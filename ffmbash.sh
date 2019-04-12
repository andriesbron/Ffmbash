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
autostart=0
output_file=""
output_dir=$(date +%Y%m%dT%H%M%S)
verbose=0
template_file=""
FPSIN=""

echo ${output_dir}
#output_dir=$(date +%Y%m%d)
#mkdir -p  /home/app/logs/"$foldername"
#sh sample.sh > /home/app/logs/"$foldername"/test$(date +%Y%m%d%H%M%S).log

function show_help {
    echo ""
    echo ""
    echo ""
    echo "    ******* ffmbash HELP *******"
    echo ""
    echo "    ${bold}NAME:${normal}"
    echo "    ffmbash start a livestream using ffmpeg (must be installed)."
    echo ""
    echo "    ${bold}USAGE:${normal}"
    echo "    ./ffmbash.sh [options]"
    echo ""
    echo "    ${bold}OPTIONS:${normal}"
    echo "    ${bold}-a${normal} Auto starts the livestream."
    echo "    ${bold}-t [template name]${normal} Loads a template with settings from the templates directory. Overrules any command line option."
    echo ""
    echo "    ${bold}AVAILABLE TEMPLATES${normal}"
    echo "    ${bold}hls_file${normal} Streams HLS to a file."
    echo "    Or... make your own and store them into the templates directory."
    echo ""
    echo "    ${bold}TRY SOMETHING?${normal}"
    echo "    ${bold}./ffmbash.sh${normal}    Guides you through all the options"
    echo ""
    echo ""
    echo ""
}

while getopts "h?avt:o:r:" opt; do
    case "$opt" in
        h|\?)
        show_help
        exit 0
        ;;
        a)  autostart=1
        ;;
        v)  verbose=1
        ;;
        t)  template_file=$OPTARG
        ;;
        o)  output_file=$OPTARG
        ;;
        r)  FPSIN=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

[ "${1:-}" = "--" ] && shift

echo "autostart=$autostart, verbose=$verbose, template_file='$template_file', output_file='$output_file', FPSIN=$FPSIN, Leftovers: $@"

#! @todo Load only the configuration file if the option is given -t hls_file

#if a template file is given, read the template and start if autostart is set.
if [ ! -z $template_file ]; then
    SAVEIFS=IFS
    IFS="="
    while read -r name value
    do
        #echo "Content of $name is ${value//\"/}"
        #! Due to lack of associative arrays:
        case "$name" in
            'ADEV') ADEV=$value;;
            'VDEV') VDEV=$value;;
            'DTSTART') DTSTART=$value;;
            'DTSTOP') DTSTOP=$value;;
            'FPSIN') FPSIN=$value;;
            'COMMAND') FPSIN=$value;;
            *);;
        esac
    done < templates/$template_file.txt
    IFS=SAVEIFS
fi

#! Setting the devices
if [ -z $ADEV ] && [ -z $VDEV ]; then
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
    read VDEV
    echo "Select the audio device (number) you want to use (leave empty for none):"
    read ADEV
    #! If no media device is selected, exit the script
    #! Works or [ ! -z $vdev ] means not empty.
    if [ -z $ADEV ] && [ -z $VDEV ]; then
        echo "Sorry, you must select either or both a video or audio device, thank you for using ffmbash."
        echo ""
        echo ""
        exit 0
    fi
fi

#! @todo ffmbashfpsin should be set later, instead, handle FPSIN here, e.g. FPSIN=${npart}.
#! Setting the framerate
if [[ ${FPSIN} == "" ]]; then
    ffmbashfpsin=""
else
    ffmbashfpsin="-framerate ${FPSIN}"
fi
if [ -z $ffmbashfpsin ]; then
    #! If the framerate is not set then a check is performed if the default framerate is working.
    SAVEIFS=IFS
    IFS=$'\n'
    echo ""
    echo "Trying stream for 1 second, one moment please..."
    
    i=0
    fpsok=true
    for line in $(ffmpeg -y -f avfoundation -i "${VDEV}:${ADEV}" -c:v libx264 -crf 0 -preset ultrafast -t 00:00:00.100 null 2>&1); do
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

echo ""
echo "Settings"
echo "Video device: "$VDEV
echo "Audio device: "$ADEV
echo "Framerate   : "${ffmbashfpsin}
echo ""
#if [ "$autostart" = false ]; then

if [ $autostart -eq 0 ]; then
    echo "Press <enter> to starting streaming. Once started, press enter <q> to quit."
    read startstreaming
fi

#! @bug Command below does not work, it breaks its neck over ${setframerate} while "${vdev}:${adev}" works. Need to use eval.
#ffmpeg -y ${setframerate} -f avfoundation -i "${vdev}:${adev}" -c:v libx264 -crf 0 -preset ultrafast test.m3u8

#command="ffmpeg -y ${ffmbashfpsin} -f avfoundation -i \"${VDEV}:${ADEV}\" -c:v libx264 -crf 0 -preset ultrafast test.m3u8"
#eval $command
mkdir -p  streams/"$output_dir"
COMMAND="ffmpeg -y ${ffmbashfpsin} -f avfoundation -i \"${VDEV}:${ADEV}\" -c:v libx264 -crf 0 -preset ultrafast streams/${output_dir}/test.m3u8"
eval $COMMAND
