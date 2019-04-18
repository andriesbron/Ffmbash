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


COMMAND="ffmpeg -y ${ffmbashfpsin} -f avfoundation -i \"${ff_vdev}:${ff_adev}\" -c:v libx264 -pix_fmt yuv420p -s 720x380 -start_number 0 -threads 25 -preset ultrafast -async 1 -hls_time 4 -hls_list_size 5 -use_localtime 1 -segment_format mpegts -hls_segment_filename 'http://localhost:8888/put/put.php?v=video-%s.ts' -f hls -method PUT 'http://localhost:8888/put/put.php?v=playlist.m3u8'"
