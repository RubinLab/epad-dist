FROM jboss/keycloak:latest

USER jboss

RUN sed -i -e 's/<web-context>auth<\/web-context>/<web-context>{keycloak_loc}\/auth<\/web-context>/' $JBOSS_HOME/standalone/configuration/standalone.xml
RUN sed -i -e 's/<web-context>auth<\/web-context>/<web-context>{keycloak_loc}\/auth<\/web-context>/' $JBOSS_HOME/standalone/configuration/standalone-ha.xml
RUN sed -i -e 's/name="\/"/name="\/{keycloak_loc}\/"/' $JBOSS_HOME/standalone/configuration/standalone.xml
RUN sed -i -e 's/name="\/"/name="\/{keycloak_loc}\/"/' $JBOSS_HOME/standalone/configuration/standalone-ha.xml
RUN sed -i -e 's/\/auth/\/{keycloak_loc}\/auth"/' $JBOSS_HOME/welcome-content/index.html