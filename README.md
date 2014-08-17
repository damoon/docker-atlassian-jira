docker-jira
===========

## Reverse Proxy Support

You need to change the `/usr/local/atlassian/jira/conf/server.xml` file to
inlude a couple of Connector (attributes)[http://tomcat.apache.org/tomcat-8.0-doc/config/http.html#Proxy_Support]

## Settings specific options

Use the `JAVA_OPTS` environment variable for changing settings with ease, this
is also used to enable Apache Portable Runtime (APR) based Native library for
Tomcat.

Add this:
```
-Datlassian.plugins.enable.wait=600
```

to enable a longer wait time for plugins to be loades (10min).



```
docker run ... --env "JAVA_OPTS" ""
```
