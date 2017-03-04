FROM usefdynamo/libsodium:0.2
MAINTAINER David Righart <david.righart@alliander.com>

ENV HOME /home/jenkins
RUN groupadd -g 10000 jenkins
RUN useradd -c "Jenkins user" -d $HOME -u 10000 -g 10000 -m jenkins
LABEL Description="This is a base image, which provides the Jenkins agent executable (slave.jar)" Vendor="Jenkins project" Version="3.5"

ARG VERSION=3.5

RUN curl --create-dirs -sSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar

COPY jenkins-slave /usr/local/bin/jenkins-slave
RUN chmod +x /usr/local/bin/jenkins-slave

USER jenkins
RUN mkdir /home/jenkins/.jenkins
VOLUME /home/jenkins/.jenkins
WORKDIR /home/jenkins

ENTRYPOINT ["jenkins-slave"]

### adding KubeCTL

ARG KUBECTL_VERSION=v1.5.2

USER root

#RUN yum -y install make gcc gcc-c++ curl
RUN yum -y install curl

RUN curl -LO https://dl.k8s.io/${KUBECTL_VERSION}/kubernetes-client-linux-amd64.tar.gz \
	&& tar xzf kubernetes-client-linux-amd64.tar.gz \
	&& rm kubernetes-client-linux-amd64.tar.gz \
	&& chmod +x ./kubernetes/client/bin/kubectl \
	&& mv ./kubernetes/client/bin/kubectl /usr/local/bin/kubectl \
	&& rm -Rf ./kubernetes

RUN curl -LO https://kubernetes-helm.storage.googleapis.com/helm-v2.2.1-linux-amd64.tar.gz \
	&& tar xzf helm-v2.2.1-linux-amd64.tar.gz \
	&& rm helm-v2.2.1-linux-amd64.tar.gz
