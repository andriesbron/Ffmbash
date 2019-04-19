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

COMMAND="-r 30 -f avfoundation -i \"${ff_vdev}:${ff_adev}\" -pix_fmt yuv420p -c:v libx264 -profile:v baseline -level 3.0 -r 24 -g 48 -keyint_min 48 -sc_threshold 0 -vb 310k -c:a mp3 -ab 40k -ar 44100 -ac 2 -f rtsp -muxdelay 0.1 rtsp://${ff_rtsp_user_name}:${ff_rtsp_user_password}@${ff_rtsp_server_url}:${ff_rtsp_server_port}/${ff_rtsp_user_name}/${ff_rtsp_key}"
