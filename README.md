# ffmbash
```MacOS```

[Work in progress]

User friendly bash bash script wrapper for livestreaming with ffmpeg on MacOS.


- To guide you through selections, type

```
./ffmbash.sh
```
Select the camera and audio device, if a framerate is required, select it, next press enter. Default, an Apple HLS video is stored in the videos directory.


- Load with a template file

```
./ffmbash.sh -t hls_file
```
Check hls_file.txt in the templates directory and see how you can manipulate the final ffmpeg command.


- Displays more help

```
./ffmbash.sh -h
```

Idea is to create your own templates and commands.


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
