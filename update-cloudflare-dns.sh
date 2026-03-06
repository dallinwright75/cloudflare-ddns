#!/bin/bash

# Put your Zone ID here
DNS_ZONE_ID='YOUR DNS ZONE ID'

# Your API token goes here
API_KEY='YOUR API TOKEN/KEY'

# The hostnames you want to update go here. This does support wildcards. 
HOST_NAMES=('web.example.com' '*.example.com')

# Gets current external IP address
CURRENT_IP_ADDRESS=$(curl -s ip.me)

# Loop through each host name, get current DNS record
for HOST_NAME in "${HOST_NAMES[@]}"; do
    # Get DNS Record
    DNS_RECORD=$(curl -sX GET "https://api.cloudflare.com/client/v4/zones/${DNS_ZONE_ID}/dns_records/?name=${HOST_NAME}" -H "Authorization: Bearer ${API_KEY}" | jq -r '.result[] | select(.name == "'${HOST_NAME}'")')
    DNS_RECORD_ID=$(echo "$DNS_RECORD" | jq -r '.id')
    CURRENT_DNS_VALUE=$(echo "$DNS_RECORD" | jq -r '.content')
    
    # If IP address has changed: update it
    if [ "$CURRENT_DNS_VALUE" != "$CURRENT_IP_ADDRESS" ]; then
        curl -sX PUT "https://api.cloudflare.com/client/v4/zones/${DNS_ZONE_ID}/dns_records/${DNS_RECORD_ID}" -H "Authorization: Bearer ${API_KEY}" -H "Content-Type:application/json" --data '{"type":"A","name":"'${HOST_NAME}'","content":"'${CURRENT_IP_ADDRESS}'"}' > /dev/null
        echo "$(date): Updated DNS record for ${HOST_NAME} to ${CURRENT_IP_ADDRESS}"
    else
        echo "$(date): No update needed for ${HOST_NAME}. Current IP: ${CURRENT_IP_ADDRESS}"
    fi
done
