FROM java:8-jre

LABEL maintainer "Aloysius Lim"
LABEL maintainer "Fabio B. Silva <fabio.bat.silva@gmail.com>"
LABEL maintainer "Clive Zagno <clivez@gmail.com>"

# Build Args
ARG PDI_RELEASE="7.0"
ARG PDI_VERSION="7.0.0.0-25"
ARG PENTAHO_DIR="/opt/pentaho"
ARG MYSQL_CONNECTOR_VERSION="5.1.41"
ARG PDI_HOME="$PENTAHO_DIR/data-integration"
ARG PDI_DOWNLOAD_URL="http://downloads.sourceforge.net/project/pentaho/Data%20Integration/$PDI_RELEASE/pdi-ce-$PDI_VERSION.zip"
ARG MYSQL_CONNECTOR_DOWNLOAD_URL="https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-$MYSQL_CONNECTOR_VERSION.tar.gz"
ARG REDSHIFT_JDBC_DOWNLOAD_URL="https://s3.amazonaws.com/redshift-downloads/drivers/RedshiftJDBC4-1.2.10.1009.jar"
ARG IC_BLOOM_PLUGIN_URL="https://github.com/Statflo/pdi-plugin-binaries/raw/master/ic-filter-plugin-2.0.0-SNAPSHOT.tar.gz"

# Read only variables
ENV PDI_PATH         "/etc/pdi"
ENV KETTLE_HOME      "$PDI_PATH"
ENV PDI_VERSION      "$PDI_VERSION"
ENV PATH             "$PATH:$PDI_HOME"
ENV CART_TEMPLATES   "$PENTAHO_DIR/templates/carte"
ENV KETTLE_TEMPLATES "$PENTAHO_DIR/templates/kettle"

# Set carte variables
ENV CARTE_NAME              "carte-server"
ENV CARTE_NETWORK_INTERFACE "eth0"
ENV CARTE_PORT              "8080"
ENV CARTE_USER              "cluster"
ENV CARTE_PASSWORD          "cluster"
ENV CARTE_IS_MASTER         "Y"
ENV CARTE_INCLUDE_MASTERS   "N"
# If CARTE_INCLUDE_MASTERS is 'Y', then these additional environment variables apply
ENV CARTE_REPORT_TO_MASTERS "Y"
ENV CARTE_MASTER_NAME       "carte-master"
ENV CARTE_MASTER_HOSTNAME   "localhost"
ENV CARTE_MASTER_PORT       "8080"
ENV CARTE_MASTER_USER       "cluster"
ENV CARTE_MASTER_PASSWORD   "cluster"
ENV CARTE_MASTER_IS_MASTER  "Y"

# Install deps
RUN apt-get update \
    && apt-get install -y libwebkitgtk-1.0-0 gettext-base vim cron python3 python3-pip git ssh \
    && rm -rf /var/lib/apt/lists/*
RUN easy_install3 -U pip

# Install PDI
RUN curl -L "$PDI_DOWNLOAD_URL" -o "/tmp/pdi-ce-$PDI_VERSION.zip" && \
    unzip -q "/tmp/pdi-ce-$PDI_VERSION.zip" -d "$PENTAHO_DIR" && \
    rm "/tmp/pdi-ce-$PDI_VERSION.zip" && \
    mkdir -p "/etc/entrypoint/conf.d" && \
    mkdir -p "$KETTLE_HOME/.kettle" && \
    mkdir -p "$PDI_PATH/carte" && \
    mkdir -p "$KETTLE_TEMPLATES" && \
    mkdir -p "$CART_TEMPLATES"

# Install MYSQL Connector
RUN curl -L "$MYSQL_CONNECTOR_DOWNLOAD_URL" | tar -xz -C /tmp/ && \
	mv "/tmp/mysql-connector-java-$MYSQL_CONNECTOR_VERSION/mysql-connector-java-$MYSQL_CONNECTOR_VERSION-bin.jar" \
		"$PDI_HOME/lib/mysql-connector-$MYSQL_CONNECTOR_VERSION.jar" && \
	rm -rf "/tmp/mysql-connector-java-$MYSQL_CONNECTOR_VERSION"

# Install Redshift drivers
RUN curl -L "$REDSHIFT_JDBC_DOWNLOAD_URL" -o /tmp/redshift_jdbc.jar && \
	mv "/tmp/redshift_jdbc.jar" "$PDI_HOME/lib/redshift_jdbc.jar"

# Install xml builder - needed for S3 plugin
RUN curl -L "http://central.maven.org/maven2/com/jamesmurty/utils/java-xmlbuilder/0.4/java-xmlbuilder-0.4.jar" -o /tmp/java-xmlbuilder-0.4.jar && \
	mv "/tmp/java-xmlbuilder-0.4.jar" "$PDI_HOME/lib/java-xmlbuilder-0.4.jar"

RUN curl -L $IC_BLOOM_PLUGIN_URL | tar xz -C /tmp && mkdir -p $PDI_HOME/plugins/steps && mv /tmp/ic-filter-plugin $PDI_HOME/plugins/steps/

# Copy carte templates
COPY carte*.xml "$CART_TEMPLATES/"

# Copy carte healthcheck
COPY carte-healthcheck.sh /usr/bin/carte-healthcheck

# Copy entrypoint
COPY entrypoint.sh /usr/bin/pdi-entrypoint

# Run entrypoint
ENTRYPOINT ["/usr/bin/pdi-entrypoint"]

# Workdir
WORKDIR "$PDI_HOME"

# Run Carte !
CMD carte.sh "$PDI_PATH/carte/carte-config.xml"
