#!/bin/sh

cp /home/dedsec/.zshrc .

git add .

git commit -m "$1"

git push 
