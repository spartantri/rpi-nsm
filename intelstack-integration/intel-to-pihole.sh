#!/bin/bash

cat > hosts << EOF
# Title: IntelStack/hosts
#
# This hosts file is a merged collection of hosts from https://intel.criticalstack.com
#
EOF

# Date: 09 April 2020 19:04:18 (UTC)
echo "# Date: $(date -u '+%d %B %Y %T (%Z)')" >> hosts

TEMP=$(mktemp /tmp/intelstack.XXXXXX)
grep Intel::DOMAIN /opt/intel-stack-client/frameworks/intel/master-public.dat |awk '{print "0.0.0.0 "$1}'|sort -u > ${TEMP}

COUNT=$(wc -l ${TEMP}|awk '{print $1}')
echo "# Number of unique domains: $(printf "%'.f\n" ${COUNT})" >> hosts

cat >> hosts << EOF
#
# Fetch the latest version of this file: https://raw.githubusercontent.com/spartantri/rpi-nsm/master/intelstack-integration/hosts
# Project home page: https://github.com/spartantri/rpi-nsm
#
# ===============================================================

127.0.0.1 localhost
EOF
cat ${TEMP} >> hosts

cat >> hosts << EOF
# End intelstack

# blacklist
#
# The contents of this file (containing a listing of additional domains in
# 'hosts' file format) are appended to the unified hosts file during the
# update process. For example, uncomment the following line to block
# 'example.com':

# 0.0.0.0 example.com
EOF
