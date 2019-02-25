FROM microsoft/azure-cli

RUN apk update \
  && apk add --no-cache jq

LABEL version="1.0.0"

LABEL maintainer="Microsoft Corporation" 
LABEL com.github.actions.name="Trigger Azure Release Pipelines" 
LABEL com.github.actions.description="GitHub Action to trigger Azure release pipeline" 
LABEL com.github.actions.color="blue"  

RUN az extension add -n azure-devops

COPY entrypoint.sh /entrypoint.sh  
RUN chmod +x /entrypoint.sh 

ENTRYPOINT ["/entrypoint.sh"]
