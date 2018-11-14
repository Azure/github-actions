#!/bin/sh

set -e

declare AZ_SCRIPT

if [ -n "$SCRIPT_PATH" ]
then
  AZ_SCRIPT = "${GITHUB_WORKSPACE}/${SCRIPT_PATH}"
else
  AZ_SCRIPT = "$*"
fi

sh -c "${AZ_SCRIPT}"