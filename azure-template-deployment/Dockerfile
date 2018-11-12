FROM microsoft/azure-cli:2.0.47

LABEL version="1.0.0"

LABEL maintainer="Disha Khakhar"
LABEL com.github.actions.name="Manage Azure Resources"
LABEL com.github.actions.description="GitHub Action to deploy ARM template to Azure"
LABEL com.github.actions.icon="triange"
LABEL com.github.actions.color="blue"

RUN apk update \
  && rm -rf /var/cache/apk/*

COPY --from=docker:stable /usr/local/bin/docker /usr/local/bin

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]