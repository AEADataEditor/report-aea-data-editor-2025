#!/bin/bash
# Convert README.md to README.pdf with the same toolchain as aeaready
# (AEADataEditor/editor-scripts): pandoc (gfm -> html5, .aeaready.css) followed by
# the aeadataeditor/html-to-pdf Docker image (Puppeteer). That image only converts
# REPLICATION.html -> REPLICATION.pdf, so we stage the files in a temp dir.

set -euo pipefail
cd "$(dirname "$0")"

DOCKERIMG=${DOCKERIMG:-aeadataeditor/html-to-pdf:latest}
CSSURL=https://raw.githubusercontent.com/AEADataEditor/editor-scripts/refs/heads/main/.aeaready.css
LOGOURL=https://raw.githubusercontent.com/AEADataEditor/editor-scripts/refs/heads/main/.logo-aea-88x88.jpg
# Local copy of editor-scripts (aeaready), if installed
AEASCRIPTS=${AEASCRIPTS:-$(dirname "$(command -v aeaready 2>/dev/null || echo /nonexistent/x)")}

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

for pair in ".aeaready.css $CSSURL" ".logo-aea-88x88.jpg $LOGOURL"; do
  set -- $pair
  if [[ -f $AEASCRIPTS/$1 ]]; then cp "$AEASCRIPTS/$1" "$work/$1"; else curl -fsSL "$2" -o "$work/$1"; fi
done

pandoc --fail-if-warnings -s README.md -f gfm -t html5 --css .aeaready.css \
  --metadata pagetitle="README: Report by the AEA Data Editor 2025" \
  -o "$work/REPLICATION.html"

# The container runs as a different user: make the staging dir accessible
chmod 777 "$work"; chmod a+r "$work"/*
docker run --rm -v "$work":/home/pptruser/project -w /home/pptruser/project "$DOCKERIMG"

[[ -s $work/REPLICATION.pdf ]] || { echo "ERROR: PDF not generated"; exit 1; }
cp "$work/REPLICATION.pdf" README.pdf
echo "Created README.pdf ($(pdfinfo README.pdf 2>/dev/null | awk '/^Pages/{print $2}') pages)"
