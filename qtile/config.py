# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

from typing import List  # noqa: F401

from libqtile import qtile,bar, layout, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal

colours = [["#141414", "#141414"], # Background
		   ["#FFFFFF", "#FFFFFF"], # Foreground
		   ["#ABB2BF", "#ABB2BF"], # Grey Colour
		   ["#E35374", "#E35374"],
		   ["#89CA78", "#89CA78"],
		   ["#F0C674", "#F0C674"],
		   ["#61AFEF", "#61AFEF"],
		   ["#D55FDE", "#D55FDE"],
		   ["#2BBAC5", "#2BBAC5"]]



mod = "mod4"
terminal = "kitty"
myTerm = "kitty"

keys = [
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "Left", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "Right", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "Down", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "Up", lazy.layout.up(), desc="Move focus up"),

    # Move windows between left/right columns or move up/down in current stack.
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(),
        desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(),
        desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(),
        desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),

    # Grow windows. If current window is on the edge of screen and direction
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "h", lazy.layout.grow_left(),
        desc="Grow window to the left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(),
        desc="Grow window to the right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(),
        desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),

    # Toggle between split and unsplit sides of stack.
    # Split = all windows displayed
    # Unsplit = 1 window displayed, like Max layout, but still with
    # multiple stack panes
    Key([mod, "shift"], "Return", lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack"),
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),

    # Toggle between different layouts as defined below
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod,"shift"], "q", lazy.window.kill(), desc="Kill focused window"),

    Key([mod, "control"], "r", lazy.restart(), desc="Restart Qtile"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawncmd(),
        desc="Spawn a command using a prompt widget"),
    Key([mod], "space", lazy.window.toggle_floating()),
    Key([mod], "f", lazy.spawn("firefox")),
    Key([mod], "b", lazy.spawn("brave")),
    Key([], "Print", lazy.spawn("flameshot gui")),
    Key([mod,"shift"], "s", lazy.spawn('''sh /home/dipesh/scripts/prompt "Suspend computer?" "systemctl suspend" && i3lock -i /home/dipesh/dotfiles/wallpapers/lockscreen.png''')),
    Key([mod,"shift"], "r", lazy.spawn('''sh /home/dipesh/scripts/prompt "Reboot computer?" "reboot"''')),
    Key([mod,"shift"], "x", lazy.spawn('''sh /home/dipesh/scripts/prompt "Shutdown computer?" "shutdown now"''')),
    # Media hotkeys
    Key([], 'XF86AudioRaiseVolume', lazy.spawn('pulseaudio-ctl up 5')),
    Key([], 'XF86AudioLowerVolume', lazy.spawn('pulseaudio-ctl down 5')),
    Key([], 'XF86AudioMute', lazy.spawn('pulseaudio-ctl set 1')),
    Key([mod],"n",lazy.screen.next_group()),
    Key([mod],"p",lazy.screen.prev_group()),
    Key([mod],"d",lazy.spawn("rofi -show drun")),
    Key([mod],"c",lazy.spawn("code")),
    Key([mod],"t",lazy.spawn("thunar")),
    Key([mod],"s",lazy.spawn("xfce4-taskmanager")),

]

groups = [Group(i) for i in "123456789"]

for i in groups:
    keys.extend([
        # mod1 + letter of group = switch to group
        Key([mod], i.name, lazy.group[i.name].toscreen(),
            desc="Switch to group {}".format(i.name)),

        # mod1 + shift + letter of group = switch to & move focused window to group
        Key([mod, "shift"], i.name, lazy.window.togroup(i.name, switch_group=False),
            desc="Switch to & move focused window to group {}".format(i.name)),
        # Or, use below if you prefer not to switch to that group.
        # # mod1 + shift + letter of group = move focused window to group
        # Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
        #     desc="move focused window to group {}".format(i.name)),
    ])
border = dict(
    border_normal='#808080',
    border_width=0,
)
layouts = [
    layout.Bsp(border_focus_stack='#d75f5f', margin=4),
    layout.Columns(border_focus_stack='#d75f5f', margin=4),
    layout.Max(border_focus_stack='#d75f5f', margin=4),
    # Try more layouts by unleashing below layouts.
    #  layout.Stack(num_stacks=1,border_focus = '#0000ff', border_normal='#000000', border_width=2),
    # layout.Matrix(),
    # layout.MonadTall(),
    # layout.MonadWide(),
    # layout.RatioTile(),
    layout.Tile(border_focus_stack='#d75f5f', margin=4),
   layout.TreeTab(
         font = "Ubuntu",
         fontsize = 10,
         sections = ["Windows"],
         section_fontsize = 10,
         border_width = 2,
         bg_color = "1c1f2499",
         active_bg = "c678dd",
         active_fg = "000000",
         inactive_bg = "a9a1e1",
         inactive_fg = "1c1f24",
         padding_left = 0,
         padding_x = 0,
         padding_y = 5,
         section_top = 10,
         section_bottom = 20,
         level_shift = 8,
         vspace = 3,
         panel_width =120
         ),
    #  layout.TreeTab(panel_width=100 ),
    # layout.VerticalTile(),
    #  layout.Zoomy(),
]

widget_defaults = dict(
    font='sans',
    fontsize=12,
    padding=3,
)
extension_defaults = widget_defaults.copy()


widgets = [
	widget.Sep(
		foreground = colours[0],
		linewidth = 4,
	),
	widget.Image(
		filename = "~/.config/qtile/py.png",
		mouse_callbacks = {"Button1": lambda: qtile.cmd_spawn("rofi -show drun")},
		scale = True,
	),
	widget.Sep(
		foreground = colours[2],
		linewidth = 1,
		padding = 10,
	),
	widget.GroupBox(
		active = colours[4],
		inactive = colours[6],
		other_current_screen_border = colours[5],
		other_screen_border = colours[2],
		this_current_screen_border = colours[7],
		this_screen_border = colours[2],
		urgent_border = colours[3],
		urgent_text = colours[3],
		disable_drag = True,
		highlight_method = 'text',
		invert_mouse_wheel = True,
		margin = 2,
		padding = 0,
		rounded = True,
		urgent_alert_method = 'text',
	),
	widget.Sep(
		foreground = colours[2],
		linewidth = 1,
		padding = 10,
	),
	widget.CurrentLayout(
		foreground = colours[7],
		font = "SF Pro Text Semibold",
	),
	widget.Systray(
		icon_size = 14,
		padding = 4,
	),
	widget.Cmus(
		noplay_color = colours[2],
		play_color = colours[1],
	),
	widget.Sep(
		foreground = colours[2],
		linewidth = 1,
		padding = 10,
	),
	widget.WindowName(
		max_chars = 75,
	),
	widget.TextBox(
		foreground = colours[3],
		font = "JetBrainsMono Nerd Font Regular",
		fontsize = 14,
		mouse_callbacks = {"Button1": lambda: qtile.cmd_spawn(myTerm + ' -e ytop')},
		padding = 0,
		text = ' '
	),
	widget.CPU(
		foreground = colours[3],
		format = '{load_percent}%',
		mouse_callbacks = {"Button1": lambda: qtile.cmd_spawn(myTerm + ' -e ytop')},
		update_interval = 20.0,
	),
	widget.Sep(
		foreground = colours[2],
		linewidth = 1,
		padding = 10,
	),
	widget.TextBox(
		foreground = colours[4],
		font = "JetBrainsMono Nerd Font Regular",
		fontsize = 14,
		mouse_callbacks = {"Button1": lambda: qtile.cmd_spawn(myTerm + ' -e ytop')},
		padding = 0,
		text = '﬙ ',
	),
	widget.Memory(
		foreground = colours[4],
		format = '{MemUsed} MB',
		mouse_callbacks = {"Button1": lambda: qtile.cmd_spawn(myTerm + ' -e ytop')},
		update_interval = 20.0,
	),
	widget.Sep(
		foreground = colours[2],
		linewidth = 1,
		padding = 10,
	),
	#widget.TextBox(
	#	foreground = colours[5],
	#	font = "JetBrainsMono Nerd Font Regular",
	#	fontsize = 12,
	#	padding = 0,
	#	text = ' ',
	#),
    widget.Backlight(
        foreground = colours[5],
        foreground_alert = colours[3],
        backlight_name = 'intel_backlight', # ls /sys/class/backlight/
        change_command = 'xbacklight set {0}',
        step = 5,
    ),
	widget.Sep(
		foreground = colours[2],
		linewidth = 1,
		padding = 10,
	),
	widget.TextBox(
		foreground = colours[5],
		font = "JetBrainsMono Nerd Font Regular",
		fontsize = 14,
		padding = 0,
		text = ' ',
	),
	widget.CheckUpdates(
		colour_have_updates = colours[5],
		colour_no_updates = colours[5],
		custom_command = 'checkupdates',
	#	custom_command = 'dnf updateinfo -q --list',
		display_format = '{updates} Updates',
	#	execute = "pkexec /usr/bin/dnf up -y",
		execute = "pkexec /usr/bin/pacman -Syu --noconfirm",
		no_update_string = 'Up to date!',
		update_interval = 18000,
	),
	widget.Sep(
		foreground = colours[2],
		linewidth = 1,
		padding = 10,
	),
	widget.TextBox(
		foreground = colours[6],
		font = "JetBrainsMono Nerd Font Regular",
		fontsize = 14,
		mouse_callbacks = ({
			"Button1": lambda: qtile.cmd_spawn("amixer -M set Master toggle"),
			"Button3": lambda: qtile.cmd_spawn("pavucontrol"),
			"Button4": lambda: qtile.cmd_spawn("amixer -M set Master 5%+ unmute"),
			"Button5": lambda: qtile.cmd_spawn("amixer -M set Master 5%- unmute"),
		}),
		padding = 0,
		text = '墳 ',
	),
	widget.Volume(
		foreground = colours[6],
		mouse_callbacks = {"Button3": lambda: qtile.cmd_spawn("pavucontrol")},
		step = 5,
	),
	widget.Sep(
		foreground = colours[2],
		linewidth = 1,
		padding = 10,
	),
	#widget.TextBox(
	#	foreground = colours[7],
	#	font = "JetBrainsMono Nerd Font Regular",
	#	fontsize = 14,
	#	padding = 0,
	#	text = '爵 ',
	#),
    widget.Net(
        foreground = colours[7],
        format = '{down}  ',
        interface = 'wlp3s0',
		update_interval = 20.0,
    ),
	widget.Sep(
		foreground = colours[2],
		linewidth = 1,
		padding = 10,
	),
	widget.Battery(
		foreground = colours[7],
		low_foreground = colours[3],
		charge_char = ' ',
		discharge_char = ' ',
		empty_char = ' ',
		full_char = ' ',
		unknown_char = ' ',
		font = "JetBrainsMono Nerd Font Regular",
		fontsize = 14,
		format = '{char}',
		low_percentage = 0.2,
		padding = 0,
		show_short_text = False,
	),
	widget.Battery(
		foreground = colours[7],
		low_foreground = colours[3],
		format = '{percent:2.0%}',
		low_percentage = 0.2,
		notify_below = 20,
	),
	widget.Sep(
		foreground = colours[2],
		linewidth = 1,
		padding = 10,
	),
	widget.TextBox(
		foreground = colours[8],
		font = "JetBrainsMono Nerd Font Regular",
		fontsize = 14,
		padding = 0,
		text = ' ',
	),
	widget.Clock(
		foreground = colours[8],
		format = '%a %b %d  %I:%M %P    ',
	),
	#widget.StockTicker(
	#	apikey = 'AESKWL5CJVHHJKR5',
	#	url = 'https://www.alphavantage.co/query?'
	#),
]

status_bar = lambda widgets: bar.Bar(widgets, 20, background = colours[0][0],opacity=0.9, margin=4)

screens = [Screen(top=status_bar(widgets),  )]


#  screens = [
#      Screen(
#          bottom=bar.Bar(
#              [
#                  widget.CurrentLayout(),
#                  widget.GroupBox(),
#                  widget.Prompt(),
#                  widget.WindowName(),
#                  widget.Chord(
#                      chords_colors={
#                          'launch': ("#ff0000", "#ffffff"),
#                      },
#                      name_transform=lambda name: name.upper(),
#                  ),
#                  widget.Systray(),
#                  widget.Net(interface="wlp3s0"),
#                  widget.Clock(format='%Y-%m-%d %a %I:%M %p'),
#                  #  widget.QuickExit(),
#              ],
#              24,
#          ),
#      ),
#  ]
#
# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(),
         start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(),
         start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front())
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: List
main = None  # WARNING: this is deprecated and will be removed soon
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(float_rules=[
    # Run the utility of `xprop` to see the wm class and name of an X client.
    *layout.Floating.default_float_rules,
    Match(wm_class='confirmreset'),  # gitk
    Match(wm_class='makebranch'),  # gitk
    Match(wm_class='maketag'),  # gitk
    Match(wm_class='ssh-askpass'),  # ssh-askpass
    Match(title='branchdialog'),  # gitk
    Match(title='pinentry'),  # GPG key password entry
])
auto_fullscreen = True
focus_on_window_activation = "smart"

# XXX: Gasp! We're lying here. In fact, nobody really uses or cares about this
# string besides java UI toolkits; you can see several discussions on the
# mailing lists, GitHub issues, and other WM documentation that suggest setting
# this string if your java app doesn't work correctly. We may as well just lie
# and say that we're a working one by default.
#
# We choose LG3D to maximize irony: it is a 3D non-reparenting WM written in
# java that happens to be on java's whitelist.
wmname = "LG3D"



import os
import subprocess
from libqtile import hook

@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser('~/.config/qtile/autostart.sh')
    subprocess.call([home])
