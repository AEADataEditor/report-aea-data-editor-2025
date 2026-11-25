#!/bin/bash

outfile=pandp-vilhuber-2025-$(date +%F).zip

zip -rp $outfile AEA*tex AEA*pdf *bib images/  tables/*tex *.cls *.sty  *.bst *.bbl sec_*tex a*tex table*tex
