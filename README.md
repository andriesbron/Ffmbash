# Ffmbash
```MacOS```

**ffmbash is a work in progress, the current status is a useful prototype, really**

User friendly bash script wrapper for livestreaming with ffmpeg (:bow:) on MacOS.

## Features
- Manual: Handpick devices and framerate by launching the bare script: ```$ ./ffmbash```.
- Command line options: Add command line options for loading templates or commands.
- Ffmpeg commands: Define ffmpeg commands that can be selected command line or in templates (see command directory).
- Templates: Define templates to configure selected ffmpeg command (see templates directory).
- Automation*: Planned start by adding a ```DTSTART``` and a ```DTEND``` item to a template.

*) Automation is done by either letting the script wait for the ```DTSTART``` time to pass or through a cron job like method. Currently, the script calculates whether it is time to start (uttermost 2 minutes upfront ```DTSTART``` event). Take notice both ```DTSTART``` and ```DTEND``` have to be provided in the template to enable automation. If you want the script to wait until the ```DTSTART``` event happens, launch ffmbash with -w option.
Automation using a cronjob might suffer issue https://github.com/andriesbron/Ffmbash/issues/11 . working on it to solve that.

**Advice:** Test your configuration before relying on it. The point is, it's a prototype and prototypes always fail when they are demonstrated.

**Notice:** If you search for template and command syntax, please verify hls_file.txt and apple_hls.sh in resp. templates and commands directory. If you stick to what is used there, you should basically get it working.

# Usage

### Concept Of Use And Defaults

The concept of Ffmbash is that a ffmpeg command is loaded by the command line option ```-c command_name``` or by the ```COMMAND``` option in a template. The ffmpeg commands are stored in a ```.sh``` file in the commands directory. You can create your own commands in ```.sh``` files, store them in the commands directory and use them also via the command line option or in a template.

Instead of command line options you can also load a template with options and load it via command line option ```-t template_name```. Using templates, you can do a few additional things, namely, automate the start of the livestream by defining a ```DTSTART``` time and a ```DTEND``` time according to .ics format.

Default the ```apple_hls``` command is loaded (```commands/apple_hls.sh```) which stores a video in a timestamp directory inside the videos directory.

### Guiding through options

Type in the terminal:

```
$ ./ffmbash.sh
```
Select the camera and audio device, if a framerate is required, select it, next press enter. Default, an Apple HLS (```commands/apple_hls.sh```) video is stored in the videos directory under the timestamp you launched the script.


### Use a particular command

Type in the terminal:

```
$ ./ffmbash.sh -c hls
```
Loads the ```hls``` command by including the file ```commands/hls.sh```.

**Attention:** Command line options are overruled by template settings. Make sure not to have a command line option configured in the template if you want to use that option at the command line.

Therefore, the following command ```$ ./ffmbash.sh -t hls_file -c hls``` loads the ```apple_hls``` command, because, the ```apple_hls``` is configured as ```COMMAND``` in the ```hls_file``` template (see ```templates/hls_file.txt```).


### Use a template file

Type in the terminal:

```
$ ./ffmbash.sh -t hls_file
```
Loads the ```hls_file``` template by parsing ```templates/hls_file.txt``` into the script. You can create your own template and manipulate the loaded ffmpeg command to your wishes.

**Attention:** Template settings overrule command line options. If you want to use command line options in combination with a template, don't use the command line option in the template.

### More help (not complete)

Type in the terminal:

```
$ ./ffmbash.sh -h
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
