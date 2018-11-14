#!/bin/bash

set -e

if [ -n "$SCRIPT_PATH" ]
then
  $SCRIPT_PATH
else
  bash "$*"
fi