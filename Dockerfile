FROM alliander/jenkins-jnlp-slave:1.0

MAINTAINER David Righart

ENV LIBSODIUM_VERSION 1.0.11

USER root

#Install some tools: gcc build tools, unzip, etc
RUN \
	yum -y update && yum clean all && \
	yum -y install install curl && \
	yum -y install make gcc gcc-c++
	
#Download and install libsodium
#https://download.libsodium.org/doc/
#Download & extract & make libsodium
#Move libsodium build
RUN \
	mkdir -p /tmpbuild/libsodium && \
	cd /tmpbuild/libsodium && \
	curl -L https://download.libsodium.org/libsodium/releases/libsodium-$LIBSODIUM_VERSION.tar.gz -o libsodium-$LIBSODIUM_VERSION.tar.gz && \
	tar xfvz libsodium-$LIBSODIUM_VERSION.tar.gz && \
	cd /tmpbuild/libsodium/libsodium-$LIBSODIUM_VERSION/ && \
	./configure && \
	make && make check && \
	make install && \
	mv src/libsodium /usr/local/ && \
	rm -Rf /tmpbuild/

#Remove compilers and make
RUN \
    yum -y remove --skip-broken gcc make gcc-c++

Define default command
CMD ["bash"]
