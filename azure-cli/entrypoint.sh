#!/bin/bash

set -e

if [ -n "$SCRIPT_PATH" ]
then
  ${GITHUB_WORKSPACE}/$SCRIPT_PATH
else
  bash "$*"
fi