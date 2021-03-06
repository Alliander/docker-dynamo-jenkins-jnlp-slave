FROM usefdynamo/libsodium:1.0.0.2.5
MAINTAINER David Righart <david.righart@alliander.com>

USER root

RUN yum -y install curl git

ENV HOME /home/jenkins
RUN groupadd -g 10000 jenkins
RUN useradd -c "Jenkins user" -d $HOME -u 10000 -g 10000 -m jenkins
LABEL Description="This is a base image, which provides the Jenkins agent executable (slave.jar)" Vendor="Jenkins project" Version="3.5"

ARG VERSION=3.23

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

ARG KUBECTL_VERSION=v1.10.5
ARG HELM_VERSION=v2.9.1

USER root

COPY google-chrome.repo /etc/yum.repos.d/google-chrome.repo

RUN curl -LO https://dl.k8s.io/${KUBECTL_VERSION}/kubernetes-client-linux-amd64.tar.gz \
        && tar xzf kubernetes-client-linux-amd64.tar.gz \
        && rm kubernetes-client-linux-amd64.tar.gz \
        && chmod +x ./kubernetes/client/bin/kubectl \
        && mv ./kubernetes/client/bin/kubectl /usr/local/bin/kubectl \
        && rm -Rf ./kubernetes \

    && curl -LO https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz \
        && tar xzf helm-${HELM_VERSION}-linux-amd64.tar.gz \
        && rm helm-${HELM_VERSION}-linux-amd64.tar.gz \
        && chmod +x ./linux-amd64/helm \
        && mv ./linux-amd64/helm /usr/local/bin/helm \
        && rm -Rf ./linux-amd64 \

# install Maven
    && curl --fail --location --retry 3 \
        https://archive.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz \
        -o /tmp/maven.tar.gz \
    && tar -zvxf /tmp/maven.tar.gz -C /opt/ \
    && \rm -f /tmp/maven.tar.gz \

# install node
    && curl --silent --location https://rpm.nodesource.com/setup_8.x | bash - \
    && yum -y install nodejs \

# install gradle
    && curl --fail --location --retry 3 \
        http://services.gradle.org/distributions/gradle-4.8.1-bin.zip \
        -o /tmp/gradle.zip \
    && unzip /tmp/gradle.zip -d /opt/ \
    && \rm -f /tmp/gradle.zip \

# install Chrome browser
    && yum install -y google-chrome-stable \

# install rng-tools to improve entropy for libsodium
    && yum install -y rng-tools \

# install `haveged` to fix slow starting Spring Boot applications
    && yum -y install make gcc gcc-c++ \
    && curl --fail --location --retry 3 \
     https://github.com/jirka-h/haveged/archive/1.9.4.tar.gz \
     -o /tmp/haveged-1.9.4.tar.gz \
    && tar zxvf /tmp/haveged-1.9.4.tar.gz -C /tmp/ \
    && cd /tmp/haveged-1.9.4 \
    && ./configure \
    && make \
    && make install \
    && cd /tmp \
    && rm -dRf /tmp/haveged-1.9.4 \
    && rm -f /tmp/haveged-1.9.4.tar.gz \
    && /usr/local/sbin/haveged -w 1024

RUN chown -R jenkins /opt/* && chgrp -R jenkins /opt/*

USER jenkins

# prepare some environment vars
ENV M2_HOME=/opt/apache-maven-3.3.9
ENV M2=$M2_HOME/bin
ENV GRADLE_HOME=/opt/gradle-4.8.1
ENV GRADLE=$GRADLE_HOME/bin
ENV PATH=$M2:$GRADLE:$PATH
ENV GRADLE_USER_HOME=/home/jenkins/.gradle

# Retrieve default libraries from gradle build file, like Spring boot etc..
COPY build.gradle /home/jenkins
COPY gradle /home/jenkins/gradle/
COPY gradlew /home/jenkins
RUN cd /home/jenkins && ./gradlew downloadDependencies && rm build.gradle

# Retrieve default libraries from npm build file
COPY package.json /home/jenkins
RUN cd /home/jenkins \
    && mkdir ~/.npm-global \
    && npm config set prefix '~/.npm-global' \
    && echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.profile \
    && source ~/.profile \
    && npm install \
    && rm package.json

# Switch back to user root, so Docker can be accessed
USER root
