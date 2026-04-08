xrandr --output DP-6 --primary
xrandr --output DP-2 --same-as DP-6
xrandr --output DP-1 --same-as DP-6
# Remove the annoying bits thing (which we need for the psychophysics room) 
shopt -s extglob
rm -rf ~/.Psychtoolbox/!(config_info_bu)