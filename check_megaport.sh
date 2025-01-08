#!/usr/bin/env bash
#
# check_megaport.sh - Centreon/Nagios plugin to check Megaport status
# with refined output messages for clarity.

# Exit codes:
#   0 = OK
#   1 = WARNING (not used here)
#   2 = CRITICAL
#   3 = UNKNOWN
#
# Prerequisites:
#   - bash
#   - curl
#   - jq

# -----------------------------
# Configuration
# -----------------------------
CLIENT_ID="xxx"
CLIENT_SECRET="xxx"

AUTH_URL="https://auth-m2m.megaport.com/oauth2/token"
PRODUCTS_URL="https://api.megaport.com/v2/products"

# -----------------------------
# Functions
# -----------------------------
die_unknown() {
  echo "UNKNOWN - $1"
  exit 3
}

# -----------------------------
# 1) Obtain OAuth2 Bearer token
# -----------------------------
TOKEN_RESPONSE=$(curl -s -X POST "$AUTH_URL" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -u "${CLIENT_ID}:${CLIENT_SECRET}" \
  --data-urlencode "grant_type=client_credentials")

if [[ -z "$TOKEN_RESPONSE" ]]; then
  die_unknown "No response from Megaport auth endpoint"
fi

ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.access_token')

if [[ -z "$ACCESS_TOKEN" || "$ACCESS_TOKEN" == "null" ]]; then
  die_unknown "Failed to obtain access token (check credentials or connectivity)."
fi

# -----------------------------
# 2) Query /v2/products
# -----------------------------
PRODUCTS_RESPONSE=$(curl -s -X GET "$PRODUCTS_URL" \
  -H "Authorization: Bearer $ACCESS_TOKEN")

if [[ -z "$PRODUCTS_RESPONSE" ]]; then
  die_unknown "No response from Megaport /v2/products"
fi

# -----------------------------
# 3) Parse & Count
# -----------------------------
TOTAL_PORTS=$(echo "$PRODUCTS_RESPONSE" | jq '.data | length')
LIVE_PORTS=$(echo "$PRODUCTS_RESPONSE" | jq '[.data[] | select(.provisioningStatus == "LIVE")] | length')
BAD_PORTS=$(( TOTAL_PORTS - LIVE_PORTS ))

TOTAL_VXCS=$(echo "$PRODUCTS_RESPONSE" | jq '[.data[] | .associatedVxcs[]?] | length')
LIVE_VXCS=$(echo "$PRODUCTS_RESPONSE" | \
  jq '[.data[] | .associatedVxcs[]? | select(.provisioningStatus == "LIVE")] | length')
BAD_VXCS=$(( TOTAL_VXCS - LIVE_VXCS ))

# -----------------------------
# 4) Determine status
# -----------------------------
if [[ "$BAD_PORTS" -eq 0 && "$BAD_VXCS" -eq 0 ]]; then
  STATUS="OK"
  EXIT_CODE=0
  HUMAN_READABLE="$STATUS - All ${TOTAL_PORTS} ports and ${TOTAL_VXCS} VXCs are LIVE."
else
  STATUS="CRITICAL"
  EXIT_CODE=2
  HUMAN_READABLE="$STATUS - ${BAD_PORTS} port(s) and ${BAD_VXCS} VXC(s) NOT LIVE out of ${TOTAL_PORTS} / ${TOTAL_VXCS}."
fi

# -----------------------------
# 5) Performance data
# -----------------------------
PERFDATA="total_ports=${TOTAL_PORTS};;;0; \
live_ports=${LIVE_PORTS};;;0; \
bad_ports=${BAD_PORTS};;;0; \
total_vxcs=${TOTAL_VXCS};;;0; \
live_vxcs=${LIVE_VXCS};;;0; \
bad_vxcs=${BAD_VXCS};;;0;"

# -----------------------------
# 6) Output & Exit
# -----------------------------
echo "${HUMAN_READABLE} | ${PERFDATA}"
exit $EXIT_CODE
