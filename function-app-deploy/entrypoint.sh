#!/bin/bash

set -e

LINUX_APP_SUBSTRING='linux'

if [[ -z $WEB_APP_NAME ]];
then 
    echo "Required Web App Name. Provide value in WEB_APP_NAME variable" >&2
    exit 1
fi
echo "Web App Name: ${WEB_APP_NAME}"

RESOURCE_GROUP_NAME=`az resource list -n "${WEB_APP_NAME}" --resource-type "Microsoft.Web/Sites" --query '[0].resourceGroup' | xargs`
if [[ -z $RESOURCE_GROUP_NAME ]];
then
    echo "Web App '${WEB_APP_NAME}' should exist before deployment." >&2
    exit 1
fi

echo "Resource Group Name: ${RESOURCE_GROUP_NAME}"

APP_KIND=`az resource show -n "${WEB_APP_NAME}" -g "${RESOURCE_GROUP_NAME}" --resource-type "Microsoft.Web/Sites" --query 'kind'` 
echo "Web App type : ${APP_KIND}"

echo "Initiating Web App Deployment"
if [[ ! $APP_KIND =~ $LINUX_APP_SUBSTRING ]];
then
    echo "Setting App Setting WEBSITE_RUN_FROM_PACKAGE = 1 ..."
    az webapp config appsettings set -g "${RESOURCE_GROUP_NAME}" -n "${WEB_APP_NAME}" --settings WEBSITE_RUN_FROM_PACKAGE=1 
    sleep 10 # TODO: find whether this app setting is updated in Kudu
    echo "Set WEBSITE_RUN_FROM_PACKAGE = 1 successfully!"
fi

if [[ -z $PACKAGE_PATH ]];
then
    PACKAGE_PATH=$GITHUB_WORKSPACE
fi

echo "Provided package path ${PACKAGE_PATH}"

if [[ -d $PACKAGE_PATH ]];
then
    echo "Compressing Package '${PACKAGE_PATH}' to '$GITHUB_WORKSPACE/PACKAGE.zip'"
    cd $PACKAGE_PATH
    zip -r "$GITHUB_WORKSPACE/PACKAGE.zip" * 
    PACKAGE_PATH="$GITHUB_WORKSPACE/PACKAGE.zip"
    cd "$GITHUB_WORKSPACE"
    echo "Compressed package. New Package path: '${PACKAGE_PATH}'"
fi

echo "Retrieving publishing credentials for the app"
PUBLISH_PROFILE=`az webapp deployment list-publishing-profiles -n ${WEB_APP_NAME} -g ${RESOURCE_GROUP_NAME}`


DEPLOYUSER=`node -pe 'JSON.parse(process.argv[1])[0].userName' ${PUBLISH_PROFILE}`
DEPLOYPASS=`node -pe 'JSON.parse(process.argv[1])[0].userPWD' ${PUBLISH_PROFILE}`

echo "Initiating Zip Deploy"
node /node_modules/typed-azure-client/runner/kuduService.js --action zipdeploy --scmUri "https://${WEB_APP_NAME}.scm.azurewebsites.net" --username $DEPLOYUSER --password $DEPLOYPASS --package "$PACKAGE_PATH"
echo "Package Deployed to Azure Web App."

DESTINATION_URL=`node -pe 'JSON.parse(process.argv[1])[0].destinationAppUrl' ${PUBLISH_PROFILE}`
echo "App Service Application URL: ${DESTINATION_URL}"


