FROM java:7

# setup useful environment variables
ENV JIRA_HOME     /var/local/atlassian/jira
ENV JIRA_INSTALL  /usr/local/atlassian/jira
ENV JIRA_VERSION  6.3.8

# install ``Atlassian Confluence``
RUN set -x \
    && apt-get install -qqy libtcnative-1 \
    && mkdir -p             "${JIRA_HOME}" \
    && chown nobody:nogroup "${JIRA_HOME}" \
    && mkdir -p             "${JIRA_INSTALL}" \
    && curl -Ls             "http://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-${JIRA_VERSION}.tar.gz" | tar -xz --directory "${JIRA_INSTALL}/" --strip-components=1 \
    && chmod -R 777         "${JIRA_INSTALL}/temp" \
    && chmod -R 777         "${JIRA_INSTALL}/logs" \
    && chmod -R 777         "${JIRA_INSTALL}/work" \
    && mkdir                "${JIRA_INSTALL}/conf/Catalina" \
    && chmod -R 777         "${JIRA_INSTALL}/conf/Catalina" \
    && echo -e              "\njira.home=$JIRA_HOME" >> "${JIRA_INSTALL}/atlassian-jira/WEB-INF/classes/jira-application.properties"

# run ``Atlassian JIRA`` as unprivileged user by default
USER nobody:nogroup

# expose default HTTP connector port
EXPOSE 8080

# set volume mount points for installation and home directory
VOLUME ["/var/local/atlassian/jira", "/usr/local/atlassian/jira"]

# run ``Atlassian Jira`` and as a foreground process by default
ENTRYPOINT ["/usr/local/atlassian/jira/bin/start-jira.sh", "-fg"]
