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

if [ -z "$GITHUB_EVENT_PATH" ]; then
    echo "GITHUB_EVENT_PATH is not set." >&2
    exit 1
fi

AZURE_BOARDS_TYPE="${AZURE_BOARDS_TYPE:-Feature}"
AZURE_BOARDS_CLOSED_STATE="${AZURE_BOARDS_CLOSED_STATE:-Done}"
AZURE_BOARDS_REOPENED_STATE="${AZURE_BOARDS_REOPENED_STATE:-New}"

AZURE_DEVOPS_URL="https://dev.azure.com/${AZURE_BOARDS_ORGANIZATION}/"
vsts configure --defaults instance="${AZURE_DEVOPS_URL}" project="${AZURE_BOARDS_PROJECT}"

vsts login --token ${AZURE_BOARDS_TOKEN}

GITHUB_ACTION=$(jq --raw-output .action "$GITHUB_EVENT_PATH")
GITHUB_ISSUE_NUMBER=$(jq --raw-output .issue.number "$GITHUB_EVENT_PATH")
AZURE_BOARDS_TITLE=$(jq --raw-output .issue.title "$GITHUB_EVENT_PATH")
AZURE_BOARDS_DESCRIPTION=$(jq --raw-output .issue.body "$GITHUB_EVENT_PATH")

case "$GITHUB_ACTION" in
"opened")
    echo "Creating work item..."
    RESULTS=$(vsts work item create --type "${AZURE_BOARDS_TYPE}" \
        --title "${AZURE_BOARDS_TITLE}" \
        --description "${AZURE_BOARDS_DESCRIPTION}" \
        -f 80="GitHub; Issue ${GITHUB_ISSUE_NUMBER}" \
        --output json)
    AZURE_BOARDS_ID=$(echo "${RESULTS}" | jq --raw-output .id)

    echo "Created work item #${AZURE_BOARDS_ID}"
    ;;
"reopened"|"closed")
    [[ "$GITHUB_ACTION" = "reopened" ]] && \
        NEW_STATE="$AZURE_BOARDS_REOPENED_STATE" || \
        NEW_STATE="$AZURE_BOARDS_CLOSED_STATE"

    echo "Looking for work items with tag 'Issue ${GITHUB_ISSUE_NUMBER}'..."
    IDS=$(vsts work item query --wiql "SELECT ID FROM workitems WHERE [System.Tags] CONTAINS 'GitHub' AND [System.Tags] CONTAINS 'Issue ${GITHUB_ISSUE_NUMBER}'" | jq '.[].id' | xargs)

    for ID in "${IDS}"; do
        echo "Setting work item ${ID} to state ${NEW_STATE}..."
        RESULTS=$(vsts work item update --id "$ID" --state "$NEW_STATE")

        RESULT_STATE=$(echo "${RESULTS}" | jq --raw-output '.fields["System.State"]')
        echo "Work item ${ID} is now ${RESULT_STATE}"
    done
    ;;
esac

