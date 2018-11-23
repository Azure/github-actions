FROM microsoft/azure-cli:2.0.47

LABEL version="1.0.0"
LABEL maintainer="Microsoft Corporation"
LABEL com.github.actions.name="Deploy to Azure WebApp"
LABEL com.github.actions.description="GitHub Action for deploying Web App on Windows and Linux"
LABEL com.github.actions.icon="cloud"
LABEL com.github.actions.color="blue"

RUN apk update && apk add nodejs=8.9.3-r1 && apk add zip

COPY . .

RUN npm install

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
