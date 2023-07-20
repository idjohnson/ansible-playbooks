#!/bin/bash
cd $1

set +x
export GITHUB_TOKEN="$2"
set -x

for PNUM in `gh pr list --json number -q '.[] | .number'`; do
   echo "PNUM: $PNUM"

   export NOWD=`date +%Y-%m-%d | tr -d '\n'`
   export DATES=`gh pr view $PNUM --json body | jq -r .body | grep 'post: ' | sed 's/.*post: \(....-..-..\).*/\1/g' | tr -d '\n'`

   if [[ "$DATES" == "$NOWD" ]]; then
      echo "TODAY! - merging now!"
      gh pr merge $PNUM --squash
   else
      echo "Not Today"
   fi
done

exit