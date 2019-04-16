# Ffmbash
```MacOS```

**ffmbash is a work in progress, the current status is a useful prototype, really**

User friendly bash script wrapper for livestreaming with ffmpeg on MacOS.

## Features
- Manual: Handpick devices and framerate as you launch the script.
- Command line options: Add command line options for loading templates or commands.
- Ffmpeg commands: Define ffmpeg commands that can be selected command line or in templates (see command directory).
- Templates: Define templates to configure selected ffmpeg command (see templates directory).
- Automation*: Planned start by adding a dtstart and a dtend item to a template.

*) Automation is done by either letting the script wait for the ```DTSTART``` time to pass or through a cron job like method. Currently, the script calculates whether it is time to start (uttermost 2 minutes upfront ```DTSTART``` event). Take notice both ```DTSTART``` and ```DTEND``` have to be provided in the template to enable automate.
Automation using a cronjob might suffer issue https://github.com/andriesbron/Ffmbash/issues/11 . working on it to solve that.

**Advice:** Test your configuration before relying on it. The point is, it's a prototype and prototypes always fail when they are demonstrated.

**Notice:** If you search for template and command syntax, please verify hls_file.txt and apple_hls.sh in resp. templates and commands directory. If you stick to what is used there, you should basically get it working.

# Usage

### Concept Of Operation And Defaults

The concept is that a particular ffmpeg command is loaded by the command line option ```-c command_name``` or the template option ```COMMAND```. These ffmpeg commands are stored in a file in the commands directory. So, create your own commands in your own files in the commands directory and start using them via command line option or in a template.

To save typing you can create templates and load these via command line option ```-t template_name```. Using templates, you can do a few additional things, namely, automate the start of the livestream by defining a ```DTSTART``` time and a ```DTEND``` time according to .ics format.

Default the apple_hls.sh command is loaded.

### Guiding through options

Type in the terminal:
```
./ffmbash.sh
```
Select the camera and audio device, if a framerate is required, select it, next press enter. Default, an Apple HLS (commands/apple_hls.sh) video is stored in the videos directory under the timestamp you launched the script.


### Use a particular command

Type in the terminal:

```
./ffmbash.sh -c hls
```
Loads the commands/hls.sh command.

**Attention:** Is overruled by template setting. So, using command line options you must be sure not to have that command defined in a template.

Therefore commands like:

```
./ffmbash.sh -t hls_file -c hls
```

will load the apple_hls command, because, that apple_hls is configured as COMMAND in hls_file.txt.


### Use a template file

Type in the terminal:

```
./ffmbash.sh -t hls_file
```
Load templates/hls_file.txt. You can create your own and modify or leave out settings to manipulate the loaded ffmpeg command.

**Attention:** Template settings overrule command line options. If you want to use command line options in combination with a template, don't use the command line option in the template.

### More help (not complete)

Type in the terminal:
```
./ffmbash.sh -h
```


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
