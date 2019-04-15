# ffmbash
```MacOS```

**ffmbash is a work in progress, the current status is a useful prototype, really**

User friendly bash script wrapper for livestreaming with ffmpeg on MacOS.

## Features
- Manual: Handpick devices and framerate as you launch the script.
- Command line options: Add command line options for loading templates or commands.
- Ffmpeg commands: Define ffmpeg commands that can be selected command line or in templates (see command directory).
- Templates: Define templates to configure selected ffmpeg command (see templates directory).
- Automation: Planned start by adding a dtstart and a dtend item to a template.

**Advice: test your configuration before relying on it.**
**Notice**
If you search for template and command syntax, please verify hls_file.txt and apple_hls.sh in resp. templates and commands directory. If you stick to what is used there, you should basically get it working.

# Modify

See templates directory and the commands directory. The naming in the template is different from the commands, however, the relation is obvious. Create your own template file and command and load it with ffmbash command line options.

# Usage


### Guiding through options

Type in the terminal:
```
./ffmbash.sh
```
Select the camera and audio device, if a framerate is required, select it, next press enter. Default, an Apple HLS video is stored in the videos directory.


### Use a template file

Type in the terminal:

```
./ffmbash.sh -t hls_file
```
Check hls_file.txt in the templates directory and see how you can manipulate the final ffmpeg command.


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
