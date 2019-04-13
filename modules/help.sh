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

bold=$(tput bold)
normal=$(tput sgr0)

echo ""
echo ""
echo "    ${bold}NAME:${normal}"
echo "    ffmbash"
echo ""
echo "    ${bold}TITLE:${normal}"
echo "    Start a livestream using ffmpeg (must be installed)."
echo ""
echo "    ${bold}USAGE:${normal}"
echo "    ./ffmbash.sh [options]"
echo ""
echo "    ${bold}DESCRIPTION:${normal}"
echo "    you can use this script in a two different ways:"
echo ""
echo "    ${bold}1) Command line input based${normal}"
echo "    Type: ${bold}./ffmbash.sh${normal} and be guided you through the options to start streaming."
echo "    ${bold}2) Template based${normal}"
echo "    Type: ${bold}./ffmbash.sh -t template_name${normal} and the template is loaded to fill the chosen ffmpeg command with the options given in the template."
echo ""
echo "    For more information on how to use and setup your own commands see:"
echo ""
echo "    http://www.github.com/andriesbron/ffmbash"
echo ""
echo "    ${bold}AVAIALBE OPTIONS:${normal}"
echo "    ${bold}-a${normal} Auto starts the livestream."
echo "    ${bold}-t [template name]${normal} Loads a template with settings from the templates directory. Settings in the template file overrule the command line option if given."
echo "    ${bold}-r [framerate]${normal} Set the input framerate."
#echo "    ${bold}-o [output file name]${normal} Enter output filename."

echo ""
echo "    ${bold}AVAILABLE TEMPLATES${normal}"
echo "    ${bold}hls_file${normal} A test template to streams HLS to a file."
echo "    Or... make your own and store them into the templates directory."
echo ""
echo "    ${bold}TRY SOMETHING?${normal}"
echo "    ${bold}./ffmbash.sh${normal}    Guides you through all the options"
echo ""
echo ""
echo ""

