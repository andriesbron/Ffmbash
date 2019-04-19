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


# Taken from https://gist.github.com/olasd/9841772
# to be worked out yet...
#@fahhu, to stream from webcam, set the SOURCE to this
#SOURCE='/dev/video0'


#! @todo fps must be a number apart from the string I create...

VBR="2500k"                                    # Bitrate de la vidéo en sortie
QUAL="medium"                                  # Preset de qualité FFMPEG
#SOURCE="udp://239.255.139.0:1234"              # Source UDP (voir les annonces SAP)

COMMAND="ffmpeg -i \"${ff_vdev}:${ff_adev}\" -deinterlace -vcodec libx264 -pix_fmt yuv420p -preset ${QUAL} ${ffmbashfpsin} -g $(($ff_fps * 2)) -b:v ${VBR} -acodec libmp3lame -ar 44100 -threads 6 -qscale 3 -b:a 712000 -bufsize 512k -f flv \"rtmp://a.rtmp.youtube.com/live2/${ff_yt_key}\""

