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


function parseics {
    #! https://stackoverflow.com/questions/6497525/print-date-for-the-monday-of-the-current-week-in-bash#6497622
    #https://www.computerhope.com/unix/udate.htm
    POINTER=false
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
            #! This has a detection span of 1 minute... that's not enough.
            
            #https://stackoverflow.com/questions/47719681/calculate-date-time-difference-in-bash-on-macos
            end=$(date -j -f "%b %d %Y %H:%M:%S" "Dec 25 2017 08:00:00" +%s)
            now=$(date +%s)
            #printf '%d seconds left till target date\n' "$(( (end-now) ))"
            #printf '%d days left till target date\n' "$(( (end-now)/86400 ))"
            
            
            if [[ ${dtstart} == *${now}* ]]; then
                echo "LIVE NOW!"
                POINTER=true
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
