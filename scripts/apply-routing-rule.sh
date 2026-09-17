#!/bin/bash
AUTH=$(echo -n "admin:***" | base64)

echo "=== Creating Routing Rule in Nexus ==="
curl -s -i -u admin:*** \
  -H "Content-Type: application/json" \
  -X POST "http://localhost:8081/service/rest/v1/routing-rules" \
  -d '{
    "name": "block-internal-names-on-public",
    "description": "Block internal package names from being fetched from public/simulated sources",
    "mode": "BLOCK",
    "matchers": [
      ".*/internal-utils.*",
      ".*/@yourorg/.*"
    ]
  }'

echo -e "\n=== Assigning Routing Rule to npm-public-sim-hosted ==="
curl -s -i -u admin:*** \
  -H "Content-Type: application/json" \
  -X PUT "http://localhost:8081/service/rest/v1/repositories/npm/hosted/npm-public-sim-hosted" \
  -d '{
    "name": "npm-public-sim-hosted",
    "online": true,
    "storage": {
      "blobStoreName": "default",
      "strictContentTypeValidation": true,
      "writePolicy": "ALLOW"
    },
    "routingRuleName": "block-internal-names-on-public"
  }'
