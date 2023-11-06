#!/bin/bash
cd $1

set +x
export GITHUB_TOKEN="$2"
set -x

git config --global user.email isaac.johnson@gmail.com
git config --global user.name "Isaac Johnson"

# run in numeric order
for PNUM in `gh pr list --json number -q '.[] | .number' | sort`; do
   echo "PNUM: $PNUM"

   # for subsequent runs, wait for the last GH Workflow to get going
   if [ -z "$firstrun" ]; then
      echo "first invokation - no wait"
      firstrun="done"
   else
      echo "better wait a few minutes"
      sleep 180
   fi
   
   # sync
   export DESTBR=`gh pr view $PNUM --json baseRefName | jq -r .baseRefName`
   export FROMBR=`gh pr view $PNUM --json headRefName | jq -r .headRefName`

   # checkout the dest (usually main)
   git checkout $DESTBR
   git pull
   
   # checkout the source branch
   git checkout $FROMBR
   git pull
   git merge --no-edit $DESTBR

   # get Modified files.. but dont match Merge:
   # for each, take ours (assume old conflicts like index.html) - in any case - future posts always should win
   git log --name-status -n 1 | grep -v ^Merge | grep ^M | sed 's/^.*\s//' | xargs -I % sh -c 'git checkout --ours "%" && git add "%" && git commit -m "fix %" && echo forced ours on "%"'

   git push
   
   # merge if time...
   export NOWD=`date +%Y-%m-%d | tr -d '\n'`
   export DATES=`gh pr view $PNUM --json body | jq -r .body | grep 'post: ' | sed 's/.*post: \(....-..-..\).*/\1/g' | tr -d '\n'`

   if [[ "$DATES" == "$NOWD" ]]; then
      echo "TODAY! - merging now!"
      gh pr merge $PNUM --squash
   else
      echo "Not Today"
   fi

   # Doing many at once requires a sleep between runs
   sleep 120
done

exit
