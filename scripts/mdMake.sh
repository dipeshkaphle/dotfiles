#!/bin/zsh

echo $1 | awk 'BEGIN {FS = "."} {print $1,$2}' | read filename ext

docker run --rm -v "$(pwd):/data" -u $(id -u):$(id -g) pandoc/latex --highlight-style=breezedark --pdf-engine=xelatex --from=markdown+tex_math_single_backslash+tex_math_dollars+raw_tex+raw_html+markdown_in_html_blocks -t latex -o "$filename.pdf" -s $1
