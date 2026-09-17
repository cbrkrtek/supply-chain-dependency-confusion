#!/usr/bin/env bash
set -euo pipefail

NEXUS_URL="${NEXUS_URL:-http://localhost:8081}"
ADMIN_USER="${NEXUS_ADMIN_USER:-admin}"

if [ -z "${NEXUS_ADMIN_PASSWORD:-}" ]; then
  read -s -p "Enter Nexus admin password: " NEXUS_ADMIN_PASSWORD
  echo ""
fi

echo "===  Initializing Nexus Repositories via REST API ==="

create_repo() {
  local repo_name="$1"
  local endpoint="$2"
  local payload="$3"
  
  echo -n "Creating repository [${repo_name}]... "
  
  HTTP_STATUS=$(curl -s -o /tmp/nexus_repo_err.json -w "%{http_code}" -u "${ADMIN_USER}:${NEXUS_ADMIN_PASSWORD}" \
    -X POST "${NEXUS_URL}/service/rest/v1/repositories/${endpoint}" \
    -H "Content-Type: application/json" \
    -d "${payload}")

  if [ "$HTTP_STATUS" -eq 201 ]; then
    echo " Created"
  elif [ "$HTTP_STATUS" -eq 400 ] || [ "$HTTP_STATUS" -eq 409 ]; then
    echo " Already exists or validation failed"
    cat /tmp/nexus_repo_err.json && echo ""
  else
    echo " HTTP $HTTP_STATUS"
    cat /tmp/nexus_repo_err.json && echo ""
  fi
}

# 1. npm-internal-hosted (hosted)
create_repo "npm-internal-hosted" "npm/hosted" '{
  "name": "npm-internal-hosted",
  "online": true,
  "storage": { "blobStoreName": "default", "writePolicy": "allow", "strictContentTypeValidation": true }
}'

# 2. npm-public-sim-hosted (hosted)
create_repo "npm-public-sim-hosted" "npm/hosted" '{
  "name": "npm-public-sim-hosted",
  "online": true,
  "storage": { "blobStoreName": "default", "writePolicy": "allow", "strictContentTypeValidation": true }
}'

# 3. npm-group (group)
create_repo "npm-group" "npm/group" '{
  "name": "npm-group",
  "online": true,
  "storage": { "blobStoreName": "default", "strictContentTypeValidation": true },
  "group": { "memberNames": ["npm-public-sim-hosted", "npm-internal-hosted"] }
}'

# 4. pypi-internal-hosted (hosted)
create_repo "pypi-internal-hosted" "pypi/hosted" '{
  "name": "pypi-internal-hosted",
  "online": true,
  "storage": { "blobStoreName": "default", "writePolicy": "allow", "strictContentTypeValidation": true }
}'

# 5. pypi-public-sim-hosted (hosted)
create_repo "pypi-public-sim-hosted" "pypi/hosted" '{
  "name": "pypi-public-sim-hosted",
  "online": true,
  "storage": { "blobStoreName": "default", "writePolicy": "allow", "strictContentTypeValidation": true }
}'

# 6. pypi-group (group)
create_repo "pypi-group" "pypi/group" '{
  "name": "pypi-group",
  "online": true,
  "storage": { "blobStoreName": "default", "strictContentTypeValidation": true },
  "group": { "memberNames": ["pypi-public-sim-hosted", "pypi-internal-hosted"] }
}'

echo -e "\n Execution finished!"