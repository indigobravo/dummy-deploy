#!/bin/bash
#
# 10_via-data.sh
#
# Script to manage external storage used by lms-via.
#
set -eu

mkdir -p /via-data

aws s3 cp s3://via-data/GDrive-Resource-Keys /via-data/
