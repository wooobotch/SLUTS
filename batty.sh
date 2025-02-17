#!/usr/bin/env sh

battery() {
  battery='/sys/class/power_supply/BAT0'

  if [ -d "$battery" ]; then
    echo -n '> Battery '

    if grep -q 'Charging' "$battery/status"; then
      echo -n 'charging '
    fi

    tr -d '\n' <"$battery/capacity"

    echo '%'
  fi
}

battery
