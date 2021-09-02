#!/bin/bash
#
# 00_papertrail.sh
#
# Configure papertrail logging for Hypothesis Elastic Beanstalk
# applications.
#
# A standard set of log files are pushed to papertrail:
# - /var/log/eb-docker/containers/eb-current-app/*.log
# - /var/log/iamsync.log
# - /var/log/nginx/*.log
#
# It should be noted that nginx logs can generate a lot of data. If
# needed a filter can be created in papertrail to exclude them.
#
# https://documentation.solarwinds.com/en/success_center/papertrail/content/kb/how-it-works/log-filtering.htm
#
set -eu

export PATH="$PATH:/opt/elasticbeanstalk/bin"

remote_archive="https://github.com/papertrail/remote_syslog2/releases/download/v0.20/remote_syslog_linux_amd64.tar.gz"
local_archive="/usr/local/share/remote_syslog_linux_amd64.tar.gz"
expected_md5='40d974d4a937868b0abc7e986b5d785c'
remote_init_file="https://raw.githubusercontent.com/papertrail/remote_syslog2/48afeaaac26d05481fb89ff53dd5522ed25b8c46/examples/remote_syslog.init.d"
eb_environment_name="$(get-config container -k environment_name || true)"
aws_metadata_url="http://169.254.169.254/latest/meta-data/instance-id"
eb_instance_id="$(wget -q -O - $aws_metadata_url)"
eb_environment_tier=$(echo $eb_environment_name |awk -F- '{print $NF}')
eb_hostname=${eb_environment_name}_${eb_instance_id}

if [[ $eb_environment_tier = 'prod' ]] ; then
  papertrail_port="33163"
fi

if [[ $eb_environment_tier = 'qa' ]] ; then
  papertrail_port="37197"
fi


curl --location --output $local_archive $remote_archive
md5_check=$(md5sum $local_archive | awk '{print $1}')
if [[ "$md5_check" != "$expected_md5" ]] ; then
  echo "md5 checksum failure. $local_archive does not match $expected_md5"
  exit 1
fi


tar --extract \
    --file $local_archive \
    --strip-components 1 \
    --directory /usr/local/bin \
    remote_syslog/remote_syslog


curl --location --output /etc/init.d/remote_syslog $remote_init_file
chmod +x /etc/init.d/remote_syslog


cat << CONFIG > /etc/log_files.yml
files:
  - /var/log/eb-docker/containers/eb-current-app/*.log
  - /var/log/iamsync.log
  - /var/log/nginx/*.log
hostname: $eb_hostname
destination:
  host: logs.papertrailapp.com
  port: $papertrail_port
  protocol: tls
CONFIG


systemctl enable remote_syslog
systemctl restart remote_syslog
