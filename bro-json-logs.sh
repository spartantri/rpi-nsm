#!bin/bash
## Configure bro to write JSON logs
mkdir -p /opt/bro/share/bro/site/scripts
sudo tee /opt/bro/share/bro/site/scripts/json-logs.bro << EOF
@load tuning/json-logs

redef LogAscii::json_timestamps = JSON::TS_ISO8601;
redef LogAscii::use_json = T;
EOF

sudo tee -a /opt/bro/share/bro/site/local.bro << EOF

# Load policy for JSON output
@load scripts/json-logs
EOF
