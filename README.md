# Ffmbash
```MacOS```

**ffmbash is a work in progress, the current status is a useful prototype, really**

User friendly bash script wrapper for livestreaming with ffmpeg (:bow:) on MacOS.

## Dependencies

Ffmpeg (:bow:). What else?

## Rationale
The idea of Ffmbash is to handle the diversity of ffmpeg (:bow:) commands often required for livestreaming or the generation of a proper media set. Ffmbash handles that complexity through the use of a template file in combination with command line options. The command line options are secondary to the templates, meaning, only use command line options in case it helps in achieving what you want, otherwise, use a template. As a result only one command line option is important, ```-t``` succeeded by the template name which will be loaded from the ```templates/``` directory.

## Features
- Livestream to Youtube using ```youtube``` template
- Livestream to an RTSP account using ```rtsp``` template
- Livestream with putHLS script, see my putHLS repo. Does not require any live streaming service but some knowledge on Apache httpd.conf and PHP to get it running.
- Create your own templates, examples included
- Create your own ffmpeg commands that can be used in templates
- Automation*: Planned start by adding a ```DTSTART``` and a ```DTEND``` item to a template.

*) Automation is done by either letting the script wait for the ```DTSTART``` event to pass or using a cron job like method. The script calculates whether it is time to start the livestream (most early 2 minutes upfront ```DTSTART``` event). 

**Attention:** Automation using a cronjob might suffer issue https://github.com/andriesbron/Ffmbash/issues/11 . working on it to solve that.

**Advice:** Test your configuration before relying on it. The point is, it's a prototype and prototypes always fail when they are demonstrated.

## Concept Of Use And Defaults

The concept of use is to load a template which then loads an ffmpeg command. The ffmpeg commands are stored in a ```.sh``` file in the commands directory. You can create your own commands in ```.sh``` files, store them in the commands directory and use them by loading them through a template or a command line option.

Default the ```apple_hls``` command is loaded (see ```commands/apple_hls.sh```) and stores a video in a timestamp directory inside the videos directory.

## Examples of usage
### Guiding through options
```
$ ./ffmbash.sh
```
Select the camera and audio device, if a framerate is required, select it, next press enter. Default, an Apple HLS (```commands/apple_hls.sh```) video is stored in the videos directory under the timestamp you launched the script.


### Use a particular command
```
$ ./ffmbash.sh -c hls
```
Loads the ```hls``` command by including the file ```commands/hls.sh```.

**Attention:** Command line options are overruled by template settings. Make sure not to have a command line option configured in the template if you want to use that option at the command line.

Therefore, the following command ```$ ./ffmbash.sh -t hls_file -c hls``` loads the ```apple_hls``` command, because, the ```apple_hls``` is configured as ```COMMAND``` in the ```hls_file``` template (see ```templates/hls_file.txt```).


### Use a template file
```
$ ./ffmbash.sh -t hls_file
```
Loads the ```hls_file``` template by parsing ```templates/hls_file.txt``` into the script. You can create your own template and manipulate the loaded ffmpeg command to your wishes.

**Attention:** Template settings overrule command line options. If you want to use command line options in combination with a template, don't use the command line option in the template.


### Automate using DTSTART and DTEND timestamp
```
$ ./ffmbash.sh -t hls_auto_start
```
Loads the ```hls_auto_start``` template (```templates/hls_auto_start.txt```) which contains a ```DTSTART``` and ```DTEND``` timestamp, additionally ```WAITFORDTSTART``` is set to "1" which causes ffmbash to remain in a loop until the ```DTSTART``` event occurs to start streaming.

```WAITFORDTSTART``` overrules the command line option -w. So, you could have left ```WAITFORDTSTART``` out of the template and start the script by:

```
$ ./ffmbash.sh -t hls_auto_start -w
```

Which produces the same result.


### Livestream to YOUTUBE
```
$ ./ffmbash.sh -t youtube
```
You should modify the youtube template in ```templates/youtube.txt``` with your personal youtube livestream key.


### Livestream to an RTSP account
```
$ ./ffmbash.sh -t rtsp
```
You should modify the rtsp template in ```templates/rtsp.txt``` with your personal rtsp account settings.


### More help (not complete)

Type in the terminal:

```
$ ./ffmbash.sh -h
```


## Overview Template Commands

Below an overview of the template commands and their parameters. The corresponding command line option is also given. 

| Template Command  | Command Line Option| Parameter       | Description |
| ---               |   -----    |   ----------------------  | ----------- |
|                   | -t [parameter]     | filename without extension  | Loads a command from the ```templates/``` directory |
| COMMAND           | -c [parameter]     | filename without extension  | Loads a command from the ```commands/``` directory |
| AUTOSTART | -a | [0,1] | Autostarts when all ffmpeg options are known, otherwise, you have to press enter before the command starts|
| VDEV  | -v [parameter] | [0,..,n]       | The enumerated value of the video device |
| ADEV  | -s [parameter] | [0,..,n]      | The enumerated value of the sound (audio) device |
| FPSIN | -r [parameter] | <0,..,n] | Input Framerate |
| SCREENRES | | widthxheight | Screen resolution |
| DTSTART  |  | .ics date format       | Start time of the livestream (requires DTEND to be set as well) |
| DTEND  |  | .ics date format       | End time of the livestream |
| WAITFORDTSTART| -w | [0,1] | Puts ffmbash in a while loop until ```DTSTART``` event happens. |
| RTSP_USER_NAME |  | Rtsp username | In combination with ```rtsp``` template | 
| RTSP_USER_PASSWORD |  | Rtsp password | In combination with ```rtsp``` template | 
| RTSP_SERVER_URL |  | Rtsp url | In combination with ```rtsp``` template |
| RTSP_SERVER_PORT |  | Rtsp url port | In combination with ```rtsp``` template | 
| RTSP_KEY |  | Rtsp stream key  | In combination with ```rtsp``` template | 
| YOUTUBE_KEY | | Youtube stream key | In combination with ```youtube``` template | 

# License
```
Ffmbash is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Ffmbash is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Ffmbash.  If not, see <http://www.gnu.org/licenses/>.
```
