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

function work_items_for_issue {
    vsts work item query --wiql "SELECT ID FROM workitems WHERE [System.Tags] CONTAINS 'GitHub' AND [System.Tags] CONTAINS 'Issue ${GITHUB_ISSUE_NUMBER}'" | jq '.[].id' | xargs
}

function issue_hyperlink {
    "Created from <a href=${GITHUB_ISSUE_HTML_URL}>Issue #${GITHUB_ISSUE_NUMBER}</a>"
}

AZURE_BOARDS_TYPE="${AZURE_BOARDS_TYPE:-Feature}"
AZURE_BOARDS_CLOSED_STATE="${AZURE_BOARDS_CLOSED_STATE:-Done}"
AZURE_BOARDS_REOPENED_STATE="${AZURE_BOARDS_REOPENED_STATE:-New}"

AZURE_DEVOPS_URL="https://dev.azure.com/${AZURE_BOARDS_ORGANIZATION}/"
vsts configure --defaults instance="${AZURE_DEVOPS_URL}" project="${AZURE_BOARDS_PROJECT}"

vsts login --token ${AZURE_BOARDS_TOKEN}

GITHUB_EVENT=$(jq --raw-output 'if .comment != null then "comment" else empty end' "$GITHUB_EVENT_PATH")
GITHUB_EVENT=${GITHUB_EVENT:-$(jq --raw-output 'if .issue != null then "issue" else empty end' "$GITHUB_EVENT_PATH")}

GITHUB_ACTION=$(jq --raw-output .action "$GITHUB_EVENT_PATH")
GITHUB_ISSUE_NUMBER=$(jq --raw-output .issue.number "$GITHUB_EVENT_PATH")
GITHUB_ISSUE_HTML_URL=$(jq --raw-output .issue.html_url "$GITHUB_EVENT_PATH")
AZURE_BOARDS_TITLE=$(jq --raw-output .issue.title "$GITHUB_EVENT_PATH")
AZURE_BOARDS_DESCRIPTION=$(jq --raw-output .issue.body "$GITHUB_EVENT_PATH")

TRIGGER="${GITHUB_EVENT}/${GITHUB_ACTION}"

case "$TRIGGER" in
"issue/opened")
    echo "Creating work item..."
    HYPERLINK=$(issue_hyperlink)
    RESULTS=$(vsts work item create --type "${AZURE_BOARDS_TYPE}" \
        --title "${AZURE_BOARDS_TITLE}" \
        --description "${AZURE_BOARDS_DESCRIPTION}" \
        -f System.Tags="GitHub; Issue ${GITHUB_ISSUE_NUMBER}" \
        --discussion "${HYPERLINK}" \
        --output json)
    AZURE_BOARDS_ID=$(echo "${RESULTS}" | jq --raw-output .id)

    echo "Created work item #${AZURE_BOARDS_ID}"
    ;;

"issue/reopened"|"issue/closed")
    [[ "$GITHUB_ACTION" = "reopened" ]] && \
        NEW_STATE="$AZURE_BOARDS_REOPENED_STATE" || \
        NEW_STATE="$AZURE_BOARDS_CLOSED_STATE"

    echo "Looking for work items with tag 'Issue ${GITHUB_ISSUE_NUMBER}'..."
    IDS=$(work_items_for_issue)

    for ID in "${IDS}"; do
        echo "Setting work item ${ID} to state ${NEW_STATE}..."
        RESULTS=$(vsts work item update --id "$ID" --state "$NEW_STATE")

        RESULT_STATE=$(echo "${RESULTS}" | jq --raw-output '.fields["System.State"]')
        echo "Work item ${ID} is now ${RESULT_STATE}"
    done
    ;;

"comment/created")
    echo "Looking for work items with tag 'Issue ${GITHUB_ISSUE_NUMBER}'..."
    IDS=$(work_items_for_issue)

    for ID in "${IDS}"; do
        HEADER="Comment from @$(jq --raw-output .comment.user.login "$GITHUB_EVENT_PATH"): "
        BODY=$(jq --raw-output .comment.body "$GITHUB_EVENT_PATH")

        echo "Adding comment to work item ${ID}..."
        RESULTS=$(vsts work item update --id "$ID" --discussion "${HEADER}${BODY}")
    done
    ;;
esac

