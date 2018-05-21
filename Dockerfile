FROM maprtech/pacc:6.0.1_5.0.0_ubuntu16


RUN apt-get update && apt-get install -y unzip nano && apt-get clean && apt-get autoremove -y


ENV APP_VER "3.1.0.0"

ENV APP_URL_BASE "https://archives.streamsets.com/datacollector/${APP_VER}/tarball"
ENV APP_URL_FILE  "streamsets-datacollector-core-${APP_VER}.tgz"
ENV APP_INST_DIR "streamsets-datacollector-$APP_VER"

ENV APP_URL "$APP_URL_BASE/$APP_URL_FILE"


ENV JAVA_VERSION_MAJOR 8
ENV JAVA_VERSION_MINOR 131
ENV JAVA_VERSION_BUILD 11
ENV JAVA_PACKAGE       server-jre
ENV JAVA_SHA256_SUM    a80634d17896fe26e432f6c2b589ef6485685b2e717c82cd36f8f747d40ec84b
ENV JAVA_URL_ELEMENT   d54c1d3a095b4ff2b6607d096fa80163

# Download and unarchive Java
RUN  mkdir -p /opt && \
  curl -jkLH "Cookie: oraclelicense=accept-securebackup-cookie" -o java.tar.gz\
    http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/${JAVA_URL_ELEMENT}/${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz && \
  echo "$JAVA_SHA256_SUM  java.tar.gz" | sha256sum -c - && \
  gunzip -c java.tar.gz | tar -xf - -C /opt && rm -f java.tar.gz && \
  ln -s /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR} /opt/jdk && \
  curl -jkLH "Cookie: oraclelicense=accept-securebackup-cookie" -o jce_policy-8.zip http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip && \
  unzip jce_policy-8.zip -d /tmp && \
  cp /tmp/UnlimitedJCEPolicyJDK8/*.jar /opt/jdk/jre/lib/security/ && \
  rm -rf jce_policy-8.zip /tmp/UnlimitedJCEPolicyJDK8

# Set environment
ENV JAVA_HOME /opt/jdk
ENV PATH ${PATH}:${JAVA_HOME}/bin

WORKDIR /opt/streamsets

RUN wget $APP_URL && tar zxf $APP_URL_FILE && rm -rf $APP_URL_FILE

WORKDIR /opt/streamsets/$APP_INST_DIR

# list all downloadable stage libraries
RUN ./bin/streamsets stagelibs -list
# install stage libraries as required

RUN ./bin/streamsets stagelibs -install=streamsets-datacollector-elasticsearch_5-lib,streamsets-datacollector-mapr_6_0-lib,streamsets-datacollector-mapr_6_0-mep4-lib,streamsets-datacollector-vault-credentialstore-lib,streamsets-datacollector-influxdb_0_9-lib,streamsets-datacollector-jdbc-lib,streamsets-datacollector-mapr_5_2-lib,streamsets-datacollector-mapr_spark_2_1_mep_3_0-lib,streamsets-datacollector-mongodb_3-lib,streamsets-datacollector-mysql-binlog-lib,streamsets-datacollector-redis-lib,streamsets-datacollector-stats-lib,streamsets-datacollector-jython_2_7-lib

RUN ./bin/streamsets stagelibs -list

#RUN chmod -R 777 /opt/streamsets/$APP_INST_DIR/etc && chmod -R 777 /opt/streamsets/$APP_INST_DIR/libexec
RUN chmod -R 777 /opt/streamsets/$APP_INST_DIR

#Update Limites
RUN echo "*               soft    nofile             32768" >> /etc/security/limits.conf
RUN echo "*               hard    nofile             32768" >> /etc/security/limits.conf


COPY init.sh /opt/streamsets
RUN chmod +x /opt/streamsets/init.sh

CMD ["/bin/bash"]


