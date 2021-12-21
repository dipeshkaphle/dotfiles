#!/bin/bash

bash ~/scripts/set_res.sh 1920 1200 60 &
xfce4-power-manager &
# bash /home/dipesh/.config/polybar/launch.sh &
picom --config '/home/dipesh/.config/picom/picom.conf' &
redshift -l 27:85 &
# feh --bg-scale ~/dotfiles/wallpapers/urban-japan-3440×1440.jpg &
feh --bg-scale ~/dotfiles/wallpapers/Water-Law-One-Piece-Anime-3840x2160-4k-Wallpaper-Hd-.jpg &
xss-lock --transfer-sleep-lock -- i3lock --nofork &
