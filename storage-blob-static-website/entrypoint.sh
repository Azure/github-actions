#!/bin/bash

set -e
export AZURE_HTTP_USER_AGENT="GITHUBACTIONS_${GITHUB_ACTION_NAME}_${GITHUB_REPOSITORY}"

# Default folder name to deploy the root directory of the website from (contains index.html etc.)
DEFAULT_PUBLIC_FOLDER="public"

# Default index file
DEFAULT_INDEX_FILE="index.html"

# Default 404 file
DEFAULT_NOT_FOUND_FILE="404.html"

if [[ -z $PUBLIC_FOLDER ]];
then 
    echo "No public folder provided in the \`PUBLIC_FOLDER\` environment variable. Defaulting to \`/${DEFAULT_PUBLIC_FOLDER}\`" >&2
    PUBLIC_FOLDER=${DEFAULT_PUBLIC_FOLDER}
fi

if [[ -z $INDEX_FILE ]];
then 
    echo "No \`index.html\` file provided in the \`INDEX_FILE\` environment variable. Defaulting to \`${DEFAULT_INDEX_FILE}\`" >&2
    INDEX_FILE=${DEFAULT_INDEX_FILE}
fi

if [[ -z $NOT_FOUND_FILE ]];
then 
    echo "No \`404.html\` file provided in the \`NOT_FOUND_FILE\` environment variable. Defaulting to \`${DEFAULT_NOT_FOUND_FILE}\`" >&2
    NOT_FOUND_FILE=${DEFAULT_NOT_FOUND_FILE}
fi

if [[ -z $SHOULD_EMPTY ]];
then 
    echo "No value provided in the \`SHOULD_EMPTY\` environment variable. Blob container \`\$web\` will not be emptied before upload" >&2
    INDEX_FILE=${DEFAULT_INDEX_FILE}
fi

# Install the Azure Storage extension (preview)
az extension add --name storage-preview

# Enable the Static Website feature on the storage accounts, in case it is not enabled
az storage blob service-properties update --static-website --404-document $NOT_FOUND_FILE --index-document $INDEX_FILE

# If user specified, empty blob container before uploading new content
if [[ $SHOULD_EMPTY = true ]];
then 
    echo "Emptying ${AZURE_STORAGE_ACCOUNT}/\$web..."
    az storage blob delete-batch -s "\$web"
    echo "Successfully emptied ${AZURE_STORAGE_ACCOUNT}/\$web"
fi

# Upload public folder in batch to blob container
echo "Uploading \`/${PUBLIC_FOLDER}\` to ${AZURE_STORAGE_ACCOUNT}/\$web..."
az storage blob upload-batch --no-progress -d "\$web" -s ${PUBLIC_FOLDER}
echo "Successfully uploaded \`/${PUBLIC_FOLDER}\` to ${AZURE_STORAGE_ACCOUNT}/\$web"
