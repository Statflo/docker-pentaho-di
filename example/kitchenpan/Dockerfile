FROM fabiobatsilva/pentaho-data-integration:7.0.0-1

LABEL maintainer "Aloysius Lim"
LABEL maintainer "Fabio B. Silva <fabio.bat.silva@gmail.com>"

COPY kettle/* $KETTLE_TEMPLATES/
COPY repo/ $KETTLE_HOME/repo/

CMD ["kitchen.sh", "-version"]
