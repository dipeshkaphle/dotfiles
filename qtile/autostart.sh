#!/bin/bash

bash ~/dotfiles/scripts/set_res.sh 1920 1200 60 &
xfce4-power-manager &
# bash /home/dipesh/.config/polybar/launch.sh &
picom --config '/home/dipesh/.config/picom/picom.conf' &
redshift -l 27:85 &
# feh --bg-scale ~/dotfiles/wallpapers/urban-japan-3440×1440.jpg &
feh --bg-scale ~/dotfiles/wallpapers/thiemeyer_road_to_samarkand.jpg &
xss-lock --transfer-sleep-lock -- i3lock -i /home/dipesh/dotfiles/wallpapers/urban-japan-3440×1440.png --nofork &
# xfce4-panel &
