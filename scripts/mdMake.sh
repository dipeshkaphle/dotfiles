#!/bin/zsh

echo $1 | awk 'BEGIN {FS = "."} {print $1,$2}' | read filename ext
pandoc --pdf-engine=xelatex --from=markdown+tex_math_single_backslash+tex_math_dollars+raw_tex -t latex -o $filename.pdf -s $1 
