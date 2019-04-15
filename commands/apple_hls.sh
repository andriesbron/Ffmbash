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


COMMAND="ffmpeg -y ${ffmbashfpsin} -f avfoundation -i \"${ff_vdev}:${ff_adev}\" -pix_fmt yuv420p -s ${ff_screen_resolution} -hls_flags round_durations -hls_time 3 -threads 25 -vcodec libx264 -ar 44100 -ab 128 -af aresample=async=1000 ${ff_set_duration} '${ff_rootdir}/${output_dir}/test.m3u8'"
