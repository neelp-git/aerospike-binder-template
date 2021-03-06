
FROM jupyter/all-spark-notebook:ubuntu-18.04
RUN pip install --no-cache-dir vdom==0.5
RUN pip install --no-cache-dir notebook
RUN pip install --no-cache-dir cryptography
RUN pip install --no-cache-dir aerospike
RUN pip install --no-cache-dir psutil

# Install Aerospike Server and Tools

USER root
ENV AEROSPIKE_VERSION 5.1.0.10
ENV AEROSPIKE_SHA256 6471c68e9492cf15a9c884f59a60f9a050ca10344f3ec35129744c7190c95987
# Install Aerospike Server and Tools

RUN \
  apt-get update -y \
  && apt-get install -y wget python lua5.2 gettext-base libldap-dev libcurl3 libcurl3-gnutls\
  && wget "https://www.aerospike.com/download/server/${AEROSPIKE_VERSION}/artifact/debian9" -O aerospike-server.tgz \
#  && echo "$AEROSPIKE_SHA256 *aerospike-server.tgz" | sha256sum -c - \
  && mkdir aerospike \
  && tar xzf aerospike-server.tgz --strip-components=1 -C aerospike \
  && dpkg -i aerospike/aerospike-server-*.deb \
#   && dpkg -i aerospike/aerospike-tools-*.deb \
  && rm -rf aerospike-server.tgz aerospike /var/lib/apt/lists/* \
  && rm -rf /opt/aerospike/lib/java \
  && apt-get purge -y \
  && apt autoremove -y 


# ENV NB_USER="asusr"
# ENV NB_UID="1000"
# ENV NB_GROUP="asgrp"
# ENV NB_GID="100"
ENV HOME /home/${NB_USER}

# Add the Aerospike configuration specific to this dockerfile
COPY aerospike.template.conf /etc/aerospike/aerospike.template.conf
COPY entrypoint.sh /entrypoint.sh
COPY aerospike ${HOME}/aerospike

# RUN adduser --disabled-password \
#    --gecos "Default user" \
#    --uid ${NB_UID} \
#    ${NB_USER}

# USER root
# RUN chown -R ${NB_UID} ${HOME}
# USER ${NB_USER}

# Expose Aerospike ports
#
#   3000 – service port, for client connections
#   3001 – fabric port, for cluster communication
#   3002 – mesh port, for cluster heartbeat
#   3003 – info port
#
EXPOSE 3000 3001 3002 3003

# ENTRYPOINT ["/entrypoint.sh"]
# CMD ["asd"]
RUN /entrypoint.sh
