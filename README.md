# Atlassian JIRA in a Docker Container

[![Build Status](https://travis-ci.org/cptactionhank/docker-atlassian-jira.svg?branch=master)](https://travis-ci.org/cptactionhank/docker-atlassian-jira)

Use the awesome magic of Docker to isolate and run Atlassian JIRA isolated and with ease.

## Getting started

To quickly get started with running a JIRA instance, first run the following command:

```bash
docker run -ti --rm -p 8080:8080 cptactionhank/jira:latest
```

Then use your browser to nagivate to `http://<yourserver>:8080/` and finish the configuration. More information can be found [here](https://confluence.atlassian.com/display/JIRA/Running+the+Setup+Wizard)

## Advanced configuration

Below is some documentation for additional configuration of the JIRA application, keep in mind this is the only tested configuration to suit own needs.

### Additional JIRA settings

Use the `CATALINA_OPTS` environment variable for changing advanced settings eg.
is also used to enable _Apache Portable Runtime (APR) based Native library for
Tomcat_ or extending plugin loading timeout.

An example running the Atlassian JIRA container with extended memory usage settings of 128MB as minimum and a maximum of 1GB.

```bash
docker run ... --env "CATALINA_OPTS=-Xms128m -Xmx1024m" cptactionhank/atlassian-jira
```

#### Plugin loading timeout

To change the plugin loading timeout to 5 minutes the following value should be added to the `CATALINA_OPTS` variable.

```
-Datlassian.plugins.enable.wait=300
```

#### Apache Portable Runtime (APR) based Native library for Tomcat

This should enable Tomcat superspeeds.

```
-Djava.library.path=/usr/lib/x86_64-linux-gnu:/usr/java/packages/lib/amd64:/usr/lib64:/lib64:/lib:/usr/lib
```

### Reverse Proxy Support

You need to change the `/usr/local/atlassian/jira/conf/server.xml` file inside the container to include a couple of Connector [attributes](http://tomcat.apache.org/tomcat-8.0-doc/config/http.html#Proxy_Support). Additional information can be found at the [JIRA documentation](https://confluence.atlassian.com/display/JIRA/Integrating+JIRA+with+Apache).

Gaining access to the `server.xml` file on a running container use the following docker command edited to suit your setup

```bash
docker run -ti --rm \
       --volumes-from <jira-container-name> \
       ubuntu:latest
```

Within this container the file can be accessed and edited to match your configuration (remember to restart the Jira container after). I recommend installing the Nano text editor unless you have the required knowledge to use vi.

#### HTTP

For a reverse proxy server listening on port 80 (HTTP) for inbound connections add and edit the following connector attributes to suit your setup.

```xml
<connector ...
   proxyName="example.com"
   proxyPort="80"
   scheme="http"
   ...
></connector>
```

#### HTTPS

For a reverse proxy server listening on port 443 (HTTPS) for inbound connections add and edit the following connector attributes to suit your setup.

```xml
<connector ...
   proxyName="example.com"
   proxyPort="443"
   scheme="https"
   ...
></connector>
```

## Upgrading Jira to a new version

First read and remember the steps from this guide [Upgrading JIRA Manually](https://confluence.atlassian.com/display/JIRA/Upgrading+JIRA+Manually) and then we'll get started. _NB. this is what i did and might not work for you or your system, but you can use it as a guideline._

### 1. So you have set your JIRA instance to read-only and made a copy of the database

1) This is depending on your choice of DBMS etc., so you're on your own here. Also let's make an XML export of the database by first exporting by the administration user interface.

2)  Then we will copy the backup file from the container to the host, but it's a bit messy because of this [open issue](https://github.com/docker/docker/issues/1992). The first thing we need to know is where the volumes path's are located on the host by:

```bash
$ JIRA_HOME=$(docker inspect --format '{{ index .Volumes "/home/jira" }}' <container-name>)
```

Use this path to gain access to the mounted container volume and created backup file, so we will copy the file like the following:

```bash
$ sudo cp $JIRA_HOME/exports/<backup-name>.zip <backup-path>
```

Congratulations we have now moved the backup file for safe keeping.

### 2. Backup the JIRA home directory

Tar+gzip compressing the JIRA home directory to a file `jira-home.tar.gz` is done by executing the following.

```bash
$ sudo tar -cpzvf jira-home.tar.gz -C $JIRA_HOME --exclude ./tmp .
```

### 3. Switch to new database

We need to restore the backup to a new container and switch the configuration to use a new empty database. The way I'll do this is first running bash process of the jira image.

```bash
docker run -ti --volume $(pwd):/backup ubuntu bash
```

Then we extract the backup by:

```bash
sudo tar -xpzvf /backup/jira-home.tar.gz -C $JIRA_HOME
```

Finally update the file `$JIRA_HOME/dbconfig.xml` to match a new __empty__ database.

### 4. Setup other customizations

Update special configurations performed on the installation directory `/usr/local/atlassian/jira` to match your needs.

### 5. Restart the container

Restart the container to use the updated settings performed in step 4 and to use the restored JIRA home directory. Now the only thing you need to do is to finish the web wizard setup and restore your data backup.

*Good Luck*

## Help, Complaints, and Additions
Create a issue on this repository and i'll have a look at it.
