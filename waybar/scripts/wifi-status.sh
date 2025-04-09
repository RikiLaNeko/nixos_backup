#!/usr/bin/env bash

# Vérification si nmcli est installé
if ! command -v nmcli &>/dev/null; then
  echo "{\"text\": \"󰤫\", \"tooltip\": \"nmcli utility is missing\"}"
  exit 1
fi

# Vérifier si le Wi-Fi est activé
wifi_status=$(nmcli radio wifi)

if [ "$wifi_status" = "disabled" ]; then
  echo "{\"text\": \"󰤮\", \"tooltip\": \"Wi-Fi Disabled\"}"
  exit 0
fi

# Recherche de la connexion active
wifi_info=$(nmcli -t -f active,ssid,signal,security dev wifi | grep "^oui")

# Si une connexion active est trouvée
if [ -n "$wifi_info" ]; then
  essid=$(echo "$wifi_info" | awk -F: '{print $2}')
  signal=$(echo "$wifi_info" | awk -F: '{print $3}')
  security=$(echo "$wifi_info" | awk -F: '{print $4}')
  tooltip="Network: ${essid}\nSecurity: ${security}\nSignal Strength: ${signal} / 100"

  # Déterminer l'icône en fonction du signal
  if [ "$signal" -ge 80 ]; then
    icon="󰤨"  # Signal fort
  elif [ "$signal" -ge 60 ]; then
    icon="󰤥"  # Signal bon
  elif [ "$signal" -ge 40 ]; then
    icon="󰤢"  # Signal faible
  elif [ "$signal" -ge 20 ]; then
    icon="󰤟"  # Signal très faible
  else
    icon="󰤯"  # Pas de signal
  fi

  echo "{\"text\": \"${icon}\", \"tooltip\": \"${tooltip}\"}"
else
  echo "{\"text\": \"󰤯\", \"tooltip\": \"No active Wi-Fi connection\"}"
fi

