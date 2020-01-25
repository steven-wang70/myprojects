FROM jetty
MAINTAINER Steven Wang
COPY ./jsoncsv.* $JETTY_BASE/webapps/
EXPOSE 8080
ENTRYPOINT java -jar $JETTY_HOME/start.jar

