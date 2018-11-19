FROM microsoft/azure-cli:2.0.47

LABEL version="1.0.0"

LABEL maintainer="Deepak Sattiraju"
LABEL com.github.actions.name="GitHub Action for Deploying an image to an AKS cluster"
LABEL com.github.actions.description="Downloads the kubeconfig of your AKS. And creates a service and a deployment with the image name provided, on the AKS cluster"
LABEL com.github.actions.icon="triange"
LABEL com.github.actions.color="blue"

RUN apk update \
  && rm -rf /var/cache/apk/* \
  && curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.12.0/bin/linux/amd64/kubectl \
  && chmod +x ./kubectl \
  && mv ./kubectl /usr/local/bin/kubectl \
  && curl https://storage.googleapis.com/kubernetes-helm/helm-v2.11.0-linux-amd64.tar.gz -o helm.tar.gz \
  && tar --extract -f helm.tar.gz \
  && chmod +x ./linux-amd64/helm \
  && mv ./linux-amd64/helm /usr/local/bin/helm

COPY --from=docker:stable /usr/local/bin/docker /usr/local/bin

COPY entrypoint.sh /
COPY default-chart /default-chart/

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
