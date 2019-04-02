FROM alpine:latest
MAINTAINER fabien.brousse@yesiddo.com

# https://kubernetes.io/docs/tasks/kubectl/install/
# latest stable kubectl: curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt
ENV KUBECTL_VERSION=v1.12.1
ENV TERRAFORM_VERSION=0.11.11
ENV HELM_VERSION=v2.12.3
ENV AWS_AUTH_VERSION=0.3.0

RUN apk --no-cache update \
  && apk --no-cache add ca-certificates python py-pip py-setuptools groff less git gnupg bash curl gawk \
  && apk --no-cache add --virtual build-dependencies make \
  && pip --no-cache-dir install awscli \
  && curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
  && mv kubectl /usr/local/bin/kubectl \
  && curl -L https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${AWS_AUTH_VERSION}/heptio-authenticator-aws_${AWS_AUTH_VERSION}_linux_amd64 -o /usr/local/bin/aws-iam-authenticator \
  && curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && mv terraform /usr/local/bin/terraform \
  && curl -LO https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz \
  && tar -zxvf helm-${HELM_VERSION}-linux-amd64.tar.gz \
  && mv linux-amd64/helm /usr/local/bin/helm \
  && chmod +x /usr/local/bin/aws-iam-authenticator /usr/local/bin/kubectl /usr/local/bin/terraform  /usr/local/bin/helm \
  && git clone https://github.com/sobolevn/git-secret.git git-secret \
  && cd git-secret && make build \
  && PREFIX="/usr/local" make install \
  && cd .. && rm -Rf git-secret \
  && apk del --purge build-dependencies \
  && rm -rf terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
  && rm -rf helm-${HELM_VERSION}-linux-amd64.tar.gz \
  && wget https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.zip\
  && unzip google-cloud-sdk.zip\
  && rm google-cloud-sdk.zip\
  && google-cloud-sdk/install.sh\
    --usage-reporting=true\
    --path-update=true\
    --bash-completion=true\
    --rc-path=/.bashrc\
    --additional-components\
    alpha\
    beta\
    bigtable\
    bq\
    cloud-datastore-emulator\
    docker-credential-gcr\
    gcd-emulator\
    gsutil\
    pubsub-emulator\
  && rm -rf /var/cache/apk/*\
  && google-cloud-sdk/bin/gcloud config set --installation component_manager/disable_update_check true\
  && sed -i -- 's/\"disable_updater\": false/\"disable_updater\": true/g' /google-cloud-sdk/lib/googlecloudsdk/core/config.json

ENV PATH "$PATH:/google-cloud-sdk/bin"

CMD ["/bin/sh"]
