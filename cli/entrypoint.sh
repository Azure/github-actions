#!/bin/sh

set -e
export AZURE_HTTP_USER_AGENT="GITHUBACTIONS_${GITHUB_ACTION} REPOSITORY_${GITHUB_REPOSITORY}"

if [ -n "$AZURE_SCRIPT_PATH" ]
then
  SCRIPT_FILE="${GITHUB_WORKSPACE}/${AZURE_SCRIPT_PATH}"
  if [[ -e "$SCRIPT_FILE" ]]
  then
    chmod +x $SCRIPT_FILE
    $SCRIPT_FILE
  else
    echo "Script file ${SCRIPT_FILE} does not exists." >&2
    exit 1
  fi
else
  sh -c "$AZURE_SCRIPT"
fi
