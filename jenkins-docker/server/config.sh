#!/bin/bash

JENKINS_URL=${JENKINS_URL:-http://localhost:8080}

if [ -f $JENKINS_HOME/config.xml ]
then
  CONFIG=$JENKINS_HOME/config.xml
else
  CONFIG=$JENKINS_REF/config.xml
fi

echo "Make Docker socket accessible by Jenkins"
groupadd -g $DOCKER_GID dockergroup
usermod -g $DOCKER_GID jenkins

xsltproc \
  --stringparam use-security $USE_SECURITY \
  --stringparam docker-url $DOCKER_HOST \
  --stringparam oauth-client-id $OAUTH_ID \
  --stringparam oauth-client-secret $OAUTH_SECRET \
  $JENKINS_REF/edit-config.xslt $CONFIG > /tmp/config.xml.new
mv /tmp/config.xml.new $CONFIG

function config {
  git config -f /etc/jenkins_jobs/jenkins_jobs.ini $1 $2
}

config jenkins.user $JENKINS_API_USER
config jenkins.password $JENKINS_API_PASSWORD
config jenkins.url $JENKINS_URL

mv /etc/jenkins_jobs/jenkins_jobs.ini /tmp/
cat /tmp/jenkins_jobs.ini | tr '-' '_' | tr -d '\t' > /etc/jenkins_jobs/jenkins_jobs.ini

chown -R jenkins:dockergroup ~jenkins
