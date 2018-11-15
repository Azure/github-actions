FROM microsoft/azure-cli:2.0.47

LABEL version="1.0.0"
LABEL maintainer="Vincent Arockiadass"
LABEL com.github.actions.name="GitHub Action for Azure Web Apps"
LABEL com.github.actions.description="GitHub Action for deploying Web App on Windows and Linux"
LABEL com.github.actions.icon="cloud-snow"
LABEL com.github.actions.color="purple"

RUN apk update && apk add nodejs && apk add zip

COPY . .

RUN npm install

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]