#!/bin/bash

set -e 

if [ -z "$AZURE_BOARDS_ORGANIZATION" ]; then
    echo "AZURE_BOARDS_ORGANIZATION is not set." >&2
    exit 1
fi

if [ -z "$AZURE_BOARDS_PROJECT" ]; then
    echo "AZURE_BOARDS_PROJECT is not set." >&2
    exit 1
fi

if [ -z "$AZURE_BOARDS_TOKEN" ]; then
    echo "AZURE_BOARDS_TOKEN is not set." >&2
    exit 1
fi

if [ -z "$AZURE_BOARDS_TYPE" ]; then
    echo "AZURE_BOARDS_TYPE is not set." >&2
    exit 1
fi

if [ -z "$GITHUB_EVENT_PATH" ]; then
    echo "GITHUB_EVENT_PATH is not set." >&2
    exit 1
fi

AZURE_DEVOPS_URL="https://dev.azure.com/${AZURE_BOARDS_ORGANIZATION}/"
vsts configure --defaults instance="${AZURE_DEVOPS_URL}" project="${AZURE_BOARDS_PROJECT}"

vsts login --token ${AZURE_BOARDS_TOKEN}

GITHUB_ACTION=$(jq --raw-output .action "$GITHUB_EVENT_PATH")
GITHUB_ISSUE_NUMBER=$(jq --raw-output .issue.number "$GITHUB_EVENT_PATH")
AZURE_BOARDS_TITLE=$(jq --raw-output .issue.title "$GITHUB_EVENT_PATH")
AZURE_BOARDS_DESCRIPTION=$(jq --raw-output .issue.body "$GITHUB_EVENT_PATH")

if [ "$GITHUB_ACTION" = "opened" ]; then
    RESULTS=$(vsts work item create --type "${AZURE_BOARDS_TYPE}" --title "${AZURE_BOARDS_TITLE}" --description "${AZURE_BOARDS_DESCRIPTION}" -f 80="GitHub; Issue ${GITHUB_ISSUE_NUMBER}" --output json)
    AZURE_BOARDS_ID=$(echo "${RESULTS}" | jq --raw-output .id)

    echo "Created work item #${AZURE_BOARDS_ID}"
fi

