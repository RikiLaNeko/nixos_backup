#!/usr/bin/env bash

# Rofi config
config="$HOME/.config/rofi/wifi-menu.rasi"

options=$(
  echo "Manual Entry"
  echo "Disable Wi-Fi"
)

wifi_list() {
  nmcli --fields "SECURITY,SSID" device wifi list |
    tail -n +2 |               # Skip the header line from nmcli output
    sed 's/  */ /g' |          # Replace multiple spaces with a single space
    sed -E "s/WPA*.?\S/🔒 /g" | # Replace 'WPA*' with a lock icon (simplified)
    sed "s/^--/🔓 /g" |         # Replace '--' (open networks) with an open icon
    sed "s/🔒  🔒/🔒/g" |        # Remove duplicate lock icons
    sed "/--/d" |              # Remove lines with empty SSIDs
    awk '!seen[$0]++'          # Filter duplicate SSIDs
}

# Test the Wi-Fi list with rofi
wifi_list_output=$(wifi_list)

echo "Options envoyées à rofi :"
echo "$options"
echo "$wifi_list_output"

# Lancer rofi avec la liste des réseaux
selected_option=$(echo "$options"$'\n'"$wifi_list_output" | rofi -dmenu -i -p "Select a Wi-Fi Network")

# Afficher l'option sélectionnée
echo "Option sélectionnée : $selected_option"

