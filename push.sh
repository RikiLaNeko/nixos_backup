#!/bin/sh

cp ~/.zshrc .

git add .

git commit -m "$1"

git push 
