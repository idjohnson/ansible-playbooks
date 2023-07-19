#!/bin/bash
set -x

cd $1

export GITHUB_TOKEN="$2"

for PNUM in `gh pr list --json number -q '.[] | .number'`; do
   echo "PNUM: $PNUM yo"
done

exit