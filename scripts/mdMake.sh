#!/bin/zsh

echo $1 | awk 'BEGIN {FS = "."} {print $1,$2}' | read filename ext
pandoc -f markdown -t latex -o $filename.pdf -s $1
