#!/bin/bash
#
# 01_newrelic_setup.sh
#
# Configure newrelic infra agent for use with Elastic Beanstalk.
#
set -eu

export PATH="$PATH:/opt/elasticbeanstalk/bin"

key=$(get-config environment -k NEW_RELIC_LICENSE_KEY || true)
display_name=$(get-config environment -k NEW_RELIC_APP_NAME || true)

if [ -z "$key" ] ; then
  echo "NEW_RELIC_LICENSE_KEY is empty"
  echo "Can not continue with NewRelic configuration - Set license key"
  exit 0
fi

if [ -z "$display_name" ] ; then
  echo "NEW_RELIC_APP_NAME is empty"
  echo "Can not continue with NewRelic configuration - Set app name"
  exit 0
fi

cat << CONFIG > /etc/newrelic-infra.yml
license_key: $key
display_name: $display_name
enable_process_metrics: false
CONFIG

curl --output /etc/yum.repos.d/newrelic-infra.repo \
     https://download.newrelic.com/infrastructure_agent/linux/yum/el/7/x86_64/newrelic-infra.repo

yum --quiet makecache --assumeyes --disablerepo='*' --enablerepo='newrelic-infra'
yum install newrelic-infra --assumeyes 
