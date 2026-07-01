#!/bin/bash

# Check if required arguments are provided
if [ $# -ne 6 ]; then
    echo "Usage: $0 <repo name> <repo to backup> <bucket> <key id> <key secret> <action: DRYRUN or DOIT>"
    echo "Example: $0 fbsnew git@gitea.freshbrewed.science:builder/fbsnew.git mytestbucket AKAIXXXX XXXXXX  DRYRUN"
    exit 1
fi

# On GIT Auth
# If using a git@URL ssh path, then we assume this host has a valid SSH key associated with that GIT repo, e.g. git@gitea.freshbrewed.science:builder/fbsnew.git
# If usingg HTTP URL, then pack the username/password in the URL, e.g. https://user:password@gitea.freshbrewed.science/builder/fbsnew.git

REPO_NAME="$1"
REPO_CLONE="$2"
BUCKET_NAME="$3"
AWSKEYID="$4"
AWSKEYSEC="$5"
ACTION="$6"

# Check if repo name directory exists
if [[ -z "$REPO_NAME" ]]; then
    echo "Error: Repo Name must be set"
    exit 1
fi

# Check if REPO_CLONE is a GIT or HTTP URL
if ! [[ "$REPO_CLONE" =~ ^(git@|http) ]]; then
    echo "Error: REPO_CLONE ($REPO_CLONE) must start with git@ or http"
    exit 1
fi

if [ "$ACTION" != "DRYRUN" ] && [ "$ACTION" != "DOIT" ]; then
	echo "Error: Action ($ACTION) must be either DRYRUN or DOIT"
    exit 1
fi

tmp_dir=`mktemp -d -t "tmp_$(date +%Y%m%d)_XXXXXXXXXX"`

echo "tmp_dir: $tmp_dir"


export GIT_TERMINAL_PROMPT=0
export GIT_SSH_COMMAND="ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new"
git clone $REPO_CLONE $tmp_dir/$REPO_NAME
echo "==========="
ls -l $tmp_dir
echo "==========="

cd $tmp_dir
export DATESTR=`date +%Y%m%d_%H%M%S`
tar -czvf ./${REPO_NAME}_${DATESTR}.tgz ./${REPO_NAME}
ls -ltra


if [ "$ACTION" == "DRYRUN" ]; then
    echo "Dry run mode"
    echo "will copy with : aws s3 cp ./${REPO_NAME}_${DATESTR}.tgz s3://${BUCKET_NAME}/${REPO_NAME}_${DATESTR}.tgz"
fi

if [ "$ACTION" == "DOIT" ]; then
    echo "Do it mode"
    set +x
    AWS_ACCESS_KEY_ID=$AWSKEYID AWS_SECRET_ACCESS_KEY=$AWSKEYSEC aws s3 cp ./${REPO_NAME}_${DATESTR}.tgz s3://${BUCKET_NAME}/${REPO_NAME}_${DATESTR}.tgz
fi

