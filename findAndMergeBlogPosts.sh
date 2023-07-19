#!/bin/bash

for PNUM in `gh pr list --json number -q '.[] | .number'`; do
   echo "PNUM: $PNUM yo"
done

exit