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

COMMAND="ffmpeg -y ${ffmbashfpsin} -f avfoundation -i \"${ff_vdev}:${ff_adev}\" -s ${ff_screen_resolution} -c:v libx264 -crf 0 -preset ultrafast \"${ff_rootdir}/${output_dir}/test.m3u8\""
