FROM microsoft/azure-cli:2.0.47

LABEL version="1.0.0"
LABEL maintainer="Microsoft Corporation"
LABEL com.github.actions.name="Deploy to Azure Function App"
LABEL com.github.actions.description="GitHub Action for deploying Function App on Windows / Linux"
LABEL com.github.actions.icon="cloud"
LABEL com.github.actions.color="blue"

ENV GITHUB_ACTION_NAME="Deploy to Azure Function App"

RUN apk update && apk add nodejs=8.9.3-r1 && apk add zip

COPY . .

RUN npm install

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
