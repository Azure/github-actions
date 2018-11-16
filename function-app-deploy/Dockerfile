FROM microsoft/azure-cli:2.0.47

LABEL version="1.0.0"
LABEL maintainer="Vincent Arockiadass"
LABEL com.github.actions.name="GitHub Action for Azure Function App Deployment"
LABEL com.github.actions.description="GitHub Action for deploying Function App on Windows / Linux"
LABEL com.github.actions.icon="cloud"
LABEL com.github.actions.color="blue"

RUN apk update && apk add nodejs && apk add zip

COPY . .

RUN npm install

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]