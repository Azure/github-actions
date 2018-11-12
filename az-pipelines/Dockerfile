FROM microsoft/vsts-cli:latest

LABEL version="1.0.0"

LABEL maintainer="Nishu Bansal" 
LABEL com.github.actions.name="GitHub Action to queue Azure build pipeline" 
LABEL com.github.actions.description="Queue build in Azure devOps" 
LABEL com.github.actions.color="blue"  

COPY entrypoint.sh /entrypoint.sh  
RUN chmod +x /entrypoint.sh 

ENTRYPOINT ["/entrypoint.sh"]