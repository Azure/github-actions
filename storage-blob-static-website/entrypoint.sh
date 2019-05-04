#!/bin/bash

set -e
export AZURE_HTTP_USER_AGENT="GITHUBACTIONS_${GITHUB_ACTION_NAME}_${GITHUB_REPOSITORY}"

# Default folder name to deploy the root directory of the website from (contains index.html etc.)
DEFAULT_PUBLIC_FOLDER="public"

if [[ -z $AZURE_STORAGE_ACCOUNT ]];
then 
    echo "A Storage Account Name is required. Please provide it in the AZURE_STORAGE_ACCOUNT environment variable" >&2
    exit 1
fi

if [[ -z $SAS_TOKEN ]];
then 
    echo "A SAS Token secret is required. Please provide it in the SAS_TOKEN secret" >&2
    exit 1
fi

if [[ -z $PUBLIC_FOLDER ]];
then 
    echo "No public folder provided in the PUBLIC_FOLDER environment variable. Defaulting to \`/${DEFAULT_PUBLIC_FOLDER}\`" >&2
    PUBLIC_FOLDER=${DEFAULT_PUBLIC_FOLDER}
fi


# Empty blob container before uploading new content
echo "Emptying ${AZURE_STORAGE_ACCOUNT}/\$web"
az storage blob delete-batch -s "\$web"
echo "Successfully emptied ${AZURE_STORAGE_ACCOUNT}/\$web"

# Upload public folder in batch to blob container
echo "Uploading \`/${PUBLIC_FOLDER}\` to ${AZURE_STORAGE_ACCOUNT}/\$web"
az storage blob upload-batch --no-progress -d "\$web" -s ${PUBLIC_FOLDER}
echo "Successfully uploaded \`/${PUBLIC_FOLDER}\` to ${AZURE_STORAGE_ACCOUNT}/\$web"
