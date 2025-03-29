#!/bin/sh

cp /home/dedsec/.zshrc .
cp /home/dedsec/.p10k.zsh .
cp -r /home/dedsec/.config/nvim nvim
cp -r /home/dedsec/.config/tmux tmux
cp -r /home/dedsec/.ssh .ssh

git add .

git commit -m "$1"

git push 
