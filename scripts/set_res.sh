#!/bin/bash

# Copyright © 2021 Chirag Bhatia

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#If no argument is specified, ask for it and exit
if [[ -z "$@" ]];
then
    echo "An argument is needed to run this script";
    exit
else
    arg="$@"
    #Basic check to make sure argument number is valid. If not, display error and exit
    if [[ $(($(echo $arg | grep -o "\s" | wc --chars) / 2 )) -ne 2 ]];
    then
        echo "Invalid Parameters. You need to specify parameters in the format \"width height refreshRate\""
        echo "For example setResolution \"1920 1080 60\""
        exit
    fi
    
    #Save stuff in variables and then use xrandr with those variables
    modename=$(echo $arg | sed 's/\s/_/g')
    display=$(xrandr | grep -Po '.+(?=\sconnected)')
    if [[ "$(xrandr|grep $modename)" = "" ]];
    then
        xrandr --newmode $modename $(gtf $(echo $arg) | grep -oP '(?<="\s\s).+') &&
        xrandr --addmode $display $modename     
    fi
    xrandr --output $display --mode $modename

    #If no error occurred, display success message
    if [[ $? -eq 0 ]];
    then
        echo "Display changed successfully to $arg"
    fi
fi

<<COMMENT
#Manual steps with explanation ahead by @debloper
# First we need to get the modeline string for xrandr
# Luckily, the tool "gtf" will help you calculate it.
# All you have to do is to pass the resolution & the-
# refresh-rate as the command parameters:
gtf 1920 1080 60
# In this case, the horizontal resolution is 1920px the
# vertical resolution is 1080px & refresh-rate is 60Hz.
# IMPORTANT: BE SURE THE MONITOR SUPPORTS THE RESOLUTION
# Typically, it outputs a line starting with "Modeline"
# e.g. "1920x1080_60.00"  172.80  1920 2040 2248 2576  1080 1081 1084 1118  -HSync +Vsync
# Copy this entire string (except for the starting "Modeline")
# Now, use "xrandr" to make the system recognize a new
# display mode. Pass the copied string as the parameter
# to the --newmode option:
xrandr --newmode "1920x1080_60.00"  172.80  1920 2040 2248 2576  1080 1081 1084 1118  -HSync +Vsync
# Well, the string within the quotes is the nick/alias
# of the display mode - you can as well pass something
# as "MyAwesomeHDResolution". But, careful! :-|
# Then all you have to do is to add the new mode to the
# display you want to apply, like this:
xrandr --addmode VGA1 "1920x1080_60.00"
# VGA1 is the display name, it might differ for you.
# Run "xrandr" without any parameters to be sure.
# The last parameter is the mode-alias/name which
# you've set in the previous command (--newmode)
# It should add the new mode to the display & apply it.
# Usually unlikely, but if it doesn't apply automatically
# then force it with this command:
xrandr --output VGA1 --mode "1920x1080_60.00"
# That's it... Enjoy the new awesome high-res display!
COMMENT
