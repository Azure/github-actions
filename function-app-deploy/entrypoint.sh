#!/bin/bash

set -e
export AZURE_HTTP_USER_AGENT="GITHUBACTIONS_${GITHUB_ACTION}"

LINUX_APP_SUBSTRING="linux"

if [[ -z $AZURE_APP_NAME ]];
then 
    echo "Required Azure Function App name. Provide value in AZURE_APP_NAME variable" >&2
    exit 1
fi

echo "Azure Function App Name: ${AZURE_APP_NAME}"

if [[ -z $AZURE_APP_PACKAGE_LOCATION ]];
then
    echo "Package location required. Provide value in AZURE_APP_PACKAGE_LOCATION variable" >&2
    exit 1
fi

if [[ ! -d "$AZURE_APP_PACKAGE_LOCATION" &&  ! -f "$AZURE_APP_PACKAGE_LOCATION" ]];
then
    echo "Package location '$AZURE_APP_PACKAGE_LOCATION' does not exist."
    exit 1
fi

RESOURCE_GROUP_NAME=`az resource list -n "${AZURE_APP_NAME}" --resource-type "Microsoft.Web/Sites" --query '[0].resourceGroup' | xargs`

if [[ -z $RESOURCE_GROUP_NAME ]];
then
    echo "Azure Function App '${AZURE_APP_NAME}' should exist before deployment." >&2
    exit 1
fi

echo "Resource Group Name: ${RESOURCE_GROUP_NAME}"

echo "Provided package path: '${AZURE_APP_PACKAGE_LOCATION}'"

if [[ -d $AZURE_APP_PACKAGE_LOCATION ]];
then
    NEW_PACKAGE_LOCATION="${GITHUB_WORKSPACE}/package_$RANDOM.zip"
    echo "Compressing Package '${AZURE_APP_PACKAGE_LOCATION}' to '$NEW_PACKAGE_LOCATION'"
    cd $AZURE_APP_PACKAGE_LOCATION
    zip -r "$NEW_PACKAGE_LOCATION" * > /dev/null
    AZURE_APP_PACKAGE_LOCATION="$NEW_PACKAGE_LOCATION"
    cd "$GITHUB_WORKSPACE"
    echo "Compressed package. New Package path: '${AZURE_APP_PACKAGE_LOCATION}'"
fi

APP_KIND=`az resource show -n "${AZURE_APP_NAME}" -g "${RESOURCE_GROUP_NAME}" --resource-type "Microsoft.Web/Sites" --query 'kind'` 

echo "Azure Function App type : ${APP_KIND}"

if [[ ! $APP_KIND =~ $LINUX_APP_SUBSTRING ]];
then
    WEBSITE_RUN_FROM_PACKAGE=`az webapp config appsettings list -n ${AZURE_APP_NAME} -g ${RESOURCE_GROUP_NAME} --query "[?(@.name=='WEBSITE_RUN_FROM_PACKAGE')].value" -o tsv`
    if [[ ! $WEBSITE_RUN_FROM_PACKAGE == "1" ]];
    then
        echo "Setting App Setting WEBSITE_RUN_FROM_PACKAGE = 1 ..."
        az webapp config appsettings set -g "${RESOURCE_GROUP_NAME}" -n "${AZURE_APP_NAME}" --settings WEBSITE_RUN_FROM_PACKAGE=1 > /dev/null
        sleep 10 # TODO: find whether this app setting is updated in Kudu
        echo "Set WEBSITE_RUN_FROM_PACKAGE = 1 successfully!"
    fi
else
    WEBSITES_ENABLE_APP_SERVICE_STORAGE=`az webapp config appsettings list -n ${AZURE_APP_NAME} -g ${RESOURCE_GROUP_NAME} --query "[?(@.name=='WEBSITES_ENABLE_APP_SERVICE_STORAGE')].value" -o tsv`
    if [[ ! $WEBSITES_ENABLE_APP_SERVICE_STORAGE == "true" ]];
    then
        echo "Setting App Setting WEBSITES_ENABLE_APP_SERVICE_STORAGE = true ..."
        az webapp config appsettings set -g "${RESOURCE_GROUP_NAME}" -n "${AZURE_APP_NAME}" --settings WEBSITES_ENABLE_APP_SERVICE_STORAGE=true > /dev/null
        sleep 10 # TODO: find whether this app setting is updated in Kudu
        echo "Set WEBSITES_ENABLE_APP_SERVICE_STORAGE = true successfully!"
    fi
fi

PUBLISH_PROFILE=`az webapp deployment list-publishing-profiles -n ${AZURE_APP_NAME} -g ${RESOURCE_GROUP_NAME}`

DEPLOYUSER=`node -pe 'JSON.parse(process.argv[1])[0].userName' "${PUBLISH_PROFILE}"`
DEPLOYPASS=`node -pe 'JSON.parse(process.argv[1])[0].userPWD' "${PUBLISH_PROFILE}"`

echo "Retrieved publishing credentials for the app."

echo "Initiating Zip Deploy"

export DEPLOYER='GITHUB'

node /node_modules/typed-azure-client/runner/kuduService.js --action zipdeploy --scmUri "https://${AZURE_APP_NAME}.scm.azurewebsites.net" --username $DEPLOYUSER --password $DEPLOYPASS --package "$AZURE_APP_PACKAGE_LOCATION"

echo "Package Deployed to Azure Function App."

DESTINATION_URL=`node -pe 'JSON.parse(process.argv[1])[0].destinationAppUrl' "${PUBLISH_PROFILE}"`
echo "Azure Function App URL: ${DESTINATION_URL}"
