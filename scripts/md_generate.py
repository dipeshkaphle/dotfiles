import os
from optparse import OptionParser

parser = OptionParser()
parser.add_option("-o", "--output", default='output.md', help="output file")
parser.add_option("-t", "--title", default='', help="title of the output file")
parser.add_option("-a", "--author", default='Dipesh Kafle', help="author of the output file")
parser.add_option("","--toc",action="store_true" ,default=False, help="print to stdout")
(options, args) = parser.parse_args()

title = ''
author = ''
boilerplate = '''---
title: {}
author : {}
toc: {}
bibliography: 'bibliography.bib'
link-citations: true
geometry: margin=1cm
urlcolor: blue
---
'''.format(options.title, options.author, (str(options.toc)).lower())


if not os.path.isfile(options.output):
    open(options.output, 'w').write(boilerplate)
