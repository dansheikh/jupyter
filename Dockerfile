FROM ubuntu:18.04

LABEL maintainer=@dansheikh

ENV DEBIAN_FRONTEND=noninteractive LANG=en_US.utf8 LC_ALL=C.UTF-8 JUPYTER_TOKEN=zeus JAVA_VERSION=jdk8u212-b04 SCALA_VERSION=2.11.12 MINICONDA_HOME=/opt/miniconda SPARK_VERSION=2.4.3 HADOOP_VERSION=2.7 GOLANG_VERSION=1.12.6 GOROOT=/usr/local/go GOPATH=/home/jupyter/go ZEROMQ_VERSION=4.3.1
ENV JAVA_HOME=/opt/${JAVA_VERSION} SCALA_HOME=/opt/scala-${SCALA_VERSION} SPARK_HOME=/opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} PATH="/opt/${JAVA_VERSION}/bin:${MINICONDA_HOME}/bin:/opt/scala-${SCALA_VERSION}/bin:${SPARK_HOME}/bin:${SPARK_HOME}/sbin:${GOROOT}/bin:${GOPATH}/bin:${PATH}"

RUN apt update --fix-missing \
  && apt install -y -q software-properties-common sudo git unzip tzdata locales curl bzip2 gnupg ca-certificates libtool pkg-config autoconf automake uuid-dev build-essential libxrender-dev \
  && rm -rf /var/lib/apt/lists/* \
  && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

RUN useradd -rm -d /home/jupyter -s /bin/bash -g root -G sudo -u 1000 jupyter \
  && passwd -d jupyter

USER jupyter

COPY environment.yml /home/jupyter/environment.yml
COPY bootstrap.sh /home/jupyter/bootstrap.sh

RUN curl -sSLo /home/jupyter/${JAVA_VERSION}.tar.gz https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/${JAVA_VERSION}/OpenJDK8U-jdk_x64_linux_hotspot_8u212b04.tar.gz \
  && sudo tar -C /opt -xzf /home/jupyter/${JAVA_VERSION}.tar.gz \
  && rm -f /home/jupyter/${JAVA_VERSION}.tar.gz

RUN curl -sSLo /home/jupyter/scala-${SCALA_VERSION}.tgz https://downloads.lightbend.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz \
  && sudo tar -C /opt -xzf /home/jupyter/scala-${SCALA_VERSION}.tgz \
  && rm -f /home/jupyter/scala-${SCALA_VERSION}.tgz

RUN curl -sSLo /home/jupyter/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
  && sudo /bin/bash /home/jupyter/miniconda.sh -b -p /opt/miniconda \
  && mkdir /home/jupyter/ipynbs \
  && rm -f /home/jupyter/miniconda.sh

RUN sudo ${MINICONDA_HOME}/bin/conda update conda \
  && sudo ${MINICONDA_HOME}/bin/conda update pip \
  && sudo ${MINICONDA_HOME}/bin/conda env create -f /home/jupyter/environment.yml \
  && . activate jupyter \
  && sudo ${MINICONDA_HOME}/bin/conda update --all

RUN curl -sSLo /home/jupyter/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz http://mirrors.ocf.berkeley.edu/apache/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
  && sudo tar -C /opt -xzf /home/jupyter/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
  && rm -f /home/jupyter/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
  && sudo ${MINICONDA_HOME}/bin/pip install --upgrade toree \
  && sudo ${MINICONDA_HOME}/bin/jupyter toree install --spark_home=${SPARK_HOME}

RUN curl -JLso /home/jupyter/zeromq-${ZEROMQ_VERSION}.tar.gz https://github.com/zeromq/libzmq/releases/download/v${ZEROMQ_VERSION}/zeromq-${ZEROMQ_VERSION}.tar.gz \
  && tar -C /home/jupyter -xzf /home/jupyter/zeromq-${ZEROMQ_VERSION}.tar.gz \
  && rm -f /home/jupyter/zeromq-${ZEROMQ_VERSION}.tar.gz \
  && cd /home/jupyter/zeromq-${ZEROMQ_VERSION} \
  && ./configure \
  && make \
  && sudo make install \
  && sudo ldconfig

RUN curl -so /home/jupyter/go${GOLANG_VERSION}.linux-amd64.tar.gz https://dl.google.com/go/go1.12.6.linux-amd64.tar.gz \
  && sudo tar -C /usr/local -xzf /home/jupyter/go${GOLANG_VERSION}.linux-amd64.tar.gz \
  && rm -f /home/jupyter/go${GOLANG_VERSION}.linux-amd64.tar.gz \
  && sudo ${GOROOT}/bin/go get -u github.com/gopherdata/gophernotes \
  && sudo ${GOROOT}/bin/go get -u gonum.org/v1/gonum/... \
  && sudo mkdir -p /home/jupyter/.local/share/jupyter/kernels/gophernotes \
  && sudo cp $GOPATH/src/github.com/gopherdata/gophernotes/kernel/* /home/jupyter/.local/share/jupyter/kernels/gophernotes

RUN sudo chown -R jupyter: /home/jupyter

CMD ["/home/jupyter/bootstrap.sh"]