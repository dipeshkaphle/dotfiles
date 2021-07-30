#!/bin/bash

xinput set-prop 10 315 1 &
xfce4-power-manager &
# bash /home/dipesh/.config/polybar/launch.sh &
picom --config '/home/dipesh/.config/picom/picom.conf' &
redshift -l 27:85 &
feh --bg-scale ~/dotfiles/wallpapers/urban-japan-3440×1440.jpg &
xss-lock --transfer-sleep-lock -- i3lock --nofork &
