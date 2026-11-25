#!/bin/bash
# Create the PUBLIC replication package for openICPSR.
# Only git-tracked files are included, so gitignored files (data/confidential/,
# jira.others.*) can never end up in the deposit. Exception: the public
# data/jira/anon/jira.anon.RDS (gitignored, but published) is added explicitly.
# For the confidential internal archive, use prepare_internal_archive.sh instead.

set -euo pipefail
cd "$(dirname "$0")"

outfile=deposit-repository-$(date +%F).zip

# What goes into the public package (paths/globs relative to repo root)
include=(
  'README.*'
  'LICENSE.txt'
  'requirements.txt'
  'global-libraries.R'
  '*.Rproj'
  '*.sh'
  '.myconfig.sh'
  'build/*'
  'programs/*'
  'tables/*'
  'images/*'
  'data/*/README*'
  'data/confidential/README.md'
  'data/jira/anon/*'
  'data/icpsr/anon*'
  'data/icpsr/icpsr.*'
  'data/scholarone/*'
  'data/zenodo/*'
)
# Never include, even if tracked
#   (prepare_internal_archive.sh references the confidential Box folder: internal only)
exclude_re='jira\.others|internal.archive|\.zip$'
# Gitignored but public files to add explicitly
extra=( data/jira/anon/jira.anon.RDS )

if [[ -n $(git status --porcelain --untracked-files=no) ]]; then
  echo "WARNING: uncommitted changes to tracked files; the working-tree version is packaged."
fi
if [[ README.md -nt README.pdf ]]; then
  echo "WARNING: README.md is newer than README.pdf - regenerate README.pdf before depositing."
fi

for f in "${extra[@]}"; do [[ -f $f ]] || { echo "ERROR: missing $f"; exit 1; }; done
files=$( (git ls-files -- "${include[@]}"; printf '%s\n' "${extra[@]}") | grep -Ev "$exclude_re" | sort -u)

rm -f "$outfile"
echo "$files" | zip -q -X "$outfile" -@

# Safety check: nothing confidential in the zip
if unzip -Z1 "$outfile" | grep -E 'data/confidential/.+\.(csv|xlsx|RDS|Rds|py|tsv)$|jira\.others|jira/raw/'; then
  echo "ERROR: confidential file found in $outfile - removing it."
  rm -f "$outfile"; exit 1
fi

echo "Created $outfile with $(unzip -Z1 "$outfile" | wc -l) files:"
unzip -l "$outfile" | tail -n +4 | head -n -2 | awk '{print "  " $4}'
