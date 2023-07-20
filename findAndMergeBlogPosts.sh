#!/bin/bash
set -x

cd $1

export GITHUB_TOKEN="$2"

for PNUM in `gh pr list --json number -q '.[] | .number'`; do
   echo "PNUM: $PNUM yo"

   export NOWD=`date +%Y-%m-%d | tr -d '\n'`
   export DATES=`gh pr view 216 --json body | jq -r .body | grep 'post: ' | sed 's/.*post: \(....-..-..\).*/\1/g' | tr -d '\n'`

   if [[ "$DATES" == "$NOWD" ]]; then
      echo "TODAY!"
   else
      echo "Not Today"
   fi
done

exit