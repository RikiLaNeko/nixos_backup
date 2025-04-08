#!/bin/sh

cp /home/dedsec/.zshrc .
cp /home/dedsec/.p10k.zsh .
cp -r /home/dedsec/.config/rofi .
cp -r /home/dedsec/.config/hypr .
cp -r /home/dedsec/.config/waybar .
cp -r /home/dedsec/.config/nvim .
cp -r /home/dedsec/.config/tmux .
cp -r /home/dedsec/.ssh .

git add .

git commit -m "$1"

git push 
