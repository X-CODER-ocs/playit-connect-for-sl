#!/bin/sh
set -eu

SYSTEMD_UNIT=/usr/lib/systemd/system/playit.service

have_command() {
  command -v "$1" >/dev/null 2>&1
}

is_upgrade() {
  case "${1:-}" in
    upgrade|upgrading|1)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

remove_legacy_unit_path() {
  legacy_unit="$1"

  if [ ! -e "$legacy_unit" ] && [ ! -L "$legacy_unit" ]; then
    return 0
  fi

  if [ "$(readlink -f "$legacy_unit" 2>/dev/null || printf '%s\n' "$legacy_unit")" = "$(readlink -f "$SYSTEMD_UNIT" 2>/dev/null || printf '%s\n' "$SYSTEMD_UNIT")" ]; then
    return 0
  fi

  rm -f "$legacy_unit"
}

if is_upgrade "${1:-}"; then
  exit 0
fi

if have_command systemctl; then
  systemctl stop playit || true
  systemctl disable playit || true
fi

remove_legacy_unit_path /lib/systemd/system/playit.service
rm -f /opt/playit/share/init/selected-manager

if [ -L /usr/bin/playit ]; then
  rm -f /usr/bin/playit
fi

if [ -L /usr/bin/playitd ]; then
  rm -f /usr/bin/playitd
fi

if [ -L /usr/local/bin/playit ]; then
  rm -f /usr/local/bin/playit
fi

if [ -L /usr/local/bin/playitd ]; then
  rm -f /usr/local/bin/playitd
fi
