if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
  exec Hyprland >/dev/null 2>&1
fi
