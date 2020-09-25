#!/bin/zsh

echo $1 | awk 'BEGIN {FS = "."} {print $1,$2}' | read filename ext
pandoc -f gfm -t latex $1 -s -o $filename.tex
pdflatex $filename.tex
rm $filename.{log,aux,tex}
