#!/bin/bash
#
# 10_set-env-var.sh
#
# Custom script to work around a limitation on the size of an
# environment variable imposed by Elastic Beanstalk.
#
# We are taking a value from the SSM parameter store and adding it to
# the `env.list` file which gets used to set Docker env vars at
# runtime.
#
set -eu

env_file="/opt/elasticbeanstalk/deployment/env.list"

google_drive_credentials=$(aws ssm get-parameter \
  --with-decryption \
  --name eb-lms-via-qa-gdc \
  --region us-west-1 \
  | jq -r .Parameter.Value
  )

echo "GOOGLE_DRIVE_CREDENTIALS=$google_drive_credentials" >> $env_file
