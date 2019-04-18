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


#! Pointer variables (variables to be used in the file that includes this module)
ICS_P_LIVENOW=false                   #! Indicates if a stream has to start right now based on ics format. "POINTER" is written in ics.sh module.
ICS_P_DURATION="00:00:00"             #! Duration of the stream when ics started. "POINTER" is written in ics.sh module.
ICS_P_EVENT_PASSED=false
ICS_P_NEXT_EVENT_DUE=""

function convertsecs() {
    ((h=${1}/3600))
    ((m=(${1}%3600)/60))
    ((s=${1}%60))
    printf "%02d:%02d:%02d\n" $h $m $s
}

function parseicstimestamp {
    if [ ! -z $2 ]; then
        now=$(date +%s)
        #! This works: date -j -f "%d-%m-%YT%H:%M:%S" "21-02-2016T21:00:00" +%s
        start=$(date -j -f "%d-%m-%YT%H:%M:%S" "$1" +%s)
        end=$(date -j -f "%d-%m-%YT%H:%M:%S" "$2" +%s)
        #! Create data to check if the stream has to start now:
        time_till_start=$(( (start-now) ))
        time_when_it_stops=$(( (end-now+60) )) #! Add a minute, because, I am a nice guy.
        #! Give the script the chance to relaunch as long as the program should go live.
        if [ $time_till_start -lt 120 ] && [ $time_when_it_stops -gt 0 ];then
            ICS_P_LIVENOW=true
            #! Now set the duration of the livestream.
            ICS_P_DURATION=$(convertsecs $time_when_it_stops)
        fi
        if [ $time_when_it_stops -lt 0 ]; then
            ICS_P_EVENT_PASSED=true
        fi
    else
        echo "No dtend is provided, cannot set automation."
    fi
}

function parseics {
    #! https://stackoverflow.com/questions/6497525/print-date-for-the-monday-of-the-current-week-in-bash#6497622
    #https://www.computerhope.com/unix/udate.htm

    #! @bug cannot get that calendar into a variable yet, downloading it and parse the file instead...
    content=$(wget $1 -q -O calendars/livestream.ics)
    # Read through the url.txt file and execute wget command for every filename
    startevent=false
    while IFS=':' read -r param value; do 
        if [[ ${param} == *'BEGIN'* ]] && [[ ${value} == *'VEVENT'* ]]; then
            startevent=true
        fi
        if [[ ${param} == *'END'* ]] && [[ ${value} == *'VEVENT'* ]]; then
            startevent=false
            echo "$dtstart_par = $dtstart"
            echo "$dtend_par = $dtend"
            echo "$rrule_par = $rrule"
            #echo "$(date +%Y%m%dT%H%M%S)"
            now="$(date +%Y%m%dT%H%M)" #! Ignore seconds.
            #! now example:     20190414T210839 
            #! dtstart example: 20190414T090000

            
            #https://stackoverflow.com/questions/47719681/calculate-date-time-difference-in-bash-on-macos
            end=$(date -j -f "%b %d %Y %H:%M:%S" "Dec 25 2017 08:00:00" +%s)
            now=$(date +%s)
            #printf '%d seconds left till target date\n' "$(( (end-now) ))"
            #printf '%d days left till target date\n' "$(( (end-now)/86400 ))"
            
            #! This has a detection span of 1 minute... that's not enough.
            if [[ ${dtstart} == *${now}* ]]; then
                echo "LIVE NOW!"
                ICS_P_LIVENOW=true
            fi
            
            case "$(date +%a)" in 
              Sat|Sun) echo "weekend";;
            esac
        fi
        
        if [ "$startevent" = true ];then
            #echo "$param >>>> $value"
            if [[ ${param} == *'DTSTART'* ]]; then
                dtstart=$value
                dtstart_par=$param
            fi
            if [[ ${param} == *'DTEND'* ]]; then
                dtend=$value
                dtend_par=$param
            fi
            if [[ ${param} == *'RRULE'* ]]; then
                rrule=$value
                rrule_par=$param
            fi
        
        fi
        
    done < calendars/livestream.ics
    return 1
}

function something {
    while IFS=: read -r key value; do
  value=${value%$'\r'} # remove DOS newlines
  if [[ $key = END && $value = VEVENT ]]; then
    handle_event # defining this function is up to you; see suggestion below
    content=( )
    tzid=( )
  else
    if [[ $key = *";TZID="* ]]; then
      tzid[${key%%";"*}]=${key##*";TZID="}
    fi
    content[${key%%";"*}]=$value
  fi
done
}

#! @todo Make a better separation between ffmbash and this module.
#! @desc Both dtstart and dtend must be set to enable automation.
#! @param $1 string DTSTART
#! @param $2 string DTEND
#! @param $3 string RRULE
#! @param $4 boolean ff_wait_for_date: if set, ics_run keeps running in a loop until the DTSTART event takes place.
function ics_run {
echo "wait "$4 " event passed: "$ICS_P_EVENT_PASSED
echo 
    if [ ! -z $1 ] && [ ! -z $2 ]; then   
        if [ $4 = true ] && [ $ICS_P_EVENT_PASSED = false ]; then
            #! if e.g. -w is set, then perform this in a loop until the stream has to start.
            while [ $ICS_P_LIVENOW = false ]; do
                echo "LIVE_NOW POINTER: "$ICS_P_LIVENOW
                parseics http://localhost:8888/livestream.ics
                #! Parsing timestamp given in the template file
                parseicstimestamp $1 $2 $ff_rrule
                sleep 3
            done
        fi
        
        #! If livenow, set the stream duration so that it automatically stops
        if [ $ICS_P_EVENT_PASSED = true ]; then
            echo "Event has passed, exiting..."
            exit 0
        fi

    fi
}
