#!/bin/bash
# IDOR Tester for Circle API
# Tests for Insecure Direct Object References

API_BASE="https://api-sandbox.circle.com"
RESULTS_DIR="/home/ubuntu/.openclaw/workspace/bugbounty/results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}=== Circle API IDOR Tester ===${NC}"
echo "Results will be saved to: $RESULTS_DIR/idor_test_$TIMESTAMP.txt"
echo ""

# Check if API keys are provided
if [ -z "$CIRCLE_API_KEY_A" ] || [ -z "$CIRCLE_API_KEY_B" ]; then
    echo -e "${RED}Error: Set CIRCLE_API_KEY_A and CIRCLE_API_KEY_B environment variables${NC}"
    echo "Usage: export CIRCLE_API_KEY_A='your_key_a'"
    echo "       export CIRCLE_API_KEY_B='your_key_b'"
    echo "       $0"
    exit 1
fi

# Function to test endpoint for IDOR
test_idor() {
    local endpoint=$1
    local description=$2
    
    echo -e "\n${YELLOW}Testing: $description${NC}"
    echo "Endpoint: $endpoint" | tee -a "$RESULTS_DIR/idor_test_$TIMESTAMP.txt"
    
    # Get resource with Account A
    echo "  [Account A] Creating/fetching resource..." | tee -a "$RESULTS_DIR/idor_test_$TIMESTAMP.txt"
    RESPONSE_A=$(curl -s -w "\n%{http_code}" -H "Authorization: Bearer $CIRCLE_API_KEY_A" \
        "$API_BASE$endpoint" 2>&1)
    HTTP_CODE_A=$(echo "$RESPONSE_A" | tail -1)
    BODY_A=$(echo "$RESPONSE_A" | head -n -1)
    
    # Try to access same resource with Account B
    echo "  [Account B] Attempting to access Account A's resource..." | tee -a "$RESULTS_DIR/idor_test_$TIMESTAMP.txt"
    RESPONSE_B=$(curl -s -w "\n%{http_code}" -H "Authorization: Bearer $CIRCLE_API_KEY_B" \
        "$API_BASE$endpoint" 2>&1)
    HTTP_CODE_B=$(echo "$RESPONSE_B" | tail -1)
    BODY_B=$(echo "$RESPONSE_B" | head -n -1)
    
    # Analyze results
    if [ "$HTTP_CODE_B" = "200" ] && [ "$HTTP_CODE_A" = "200" ]; then
        if [ "$BODY_A" = "$BODY_B" ]; then
            echo -e "  ${RED}✗ VULNERABLE: Account B can access Account A's data!${NC}" | tee -a "$RESULTS_DIR/idor_test_$TIMESTAMP.txt"
            echo "  Response: $BODY_B" | tee -a "$RESULTS_DIR/idor_test_$TIMESTAMP.txt"
            return 0
        else
            echo -e "  ${GREEN}✓ SAFE: Different data returned${NC}" | tee -a "$RESULTS_DIR/idor_test_$TIMESTAMP.txt"
            return 1
        fi
    elif [ "$HTTP_CODE_B" = "403" ] || [ "$HTTP_CODE_B" = "401" ]; then
        echo -e "  ${GREEN}✓ SAFE: Properly denied (HTTP $HTTP_CODE_B)${NC}" | tee -a "$RESULTS_DIR/idor_test_$TIMESTAMP.txt"
        return 1
    elif [ "$HTTP_CODE_B" = "404" ]; then
        echo -e "  ${YELLOW}? NOT FOUND: Resource doesn't exist or is hidden (HTTP 404)${NC}" | tee -a "$RESULTS_DIR/idor_test_$TIMESTAMP.txt"
        return 1
    else
        echo -e "  ${YELLOW}? UNEXPECTED: HTTP $HTTP_CODE_B${NC}" | tee -a "$RESULTS_DIR/idor_test_$TIMESTAMP.txt"
        echo "  Response: $BODY_B" | tee -a "$RESULTS_DIR/idor_test_$TIMESTAMP.txt"
        return 1
    fi
}

# Main testing
echo "Starting IDOR tests at $(date)" > "$RESULTS_DIR/idor_test_$TIMESTAMP.txt"
echo "=================================" >> "$RESULTS_DIR/idor_test_$TIMESTAMP.txt"

# Test common endpoints (you'll need to fill in actual IDs)
echo -e "\n${YELLOW}Note: You need to provide actual resource IDs to test${NC}"
echo "Edit this script and add your test cases below:"
echo ""
echo "# Example test cases:"
echo "# test_idor \"/v1/wallets/WALLET_ID_FROM_ACCOUNT_A\" \"Wallet Access\""
echo "# test_idor \"/v1/businesses/BUSINESS_ID\" \"Business Account Access\""
echo "# test_idor \"/v1/transfers/TRANSFER_ID\" \"Transfer History Access\""
echo ""

# Placeholder for actual tests
# Uncomment and modify these lines with real IDs:
# test_idor "/v1/wallets/your-wallet-id-here" "Wallet IDOR Test"
# test_idor "/v1/businesses/your-business-id" "Business IDOR Test"

echo -e "\n${YELLOW}IDOR testing complete!${NC}"
echo -e "Results saved to: ${GREEN}$RESULTS_DIR/idor_test_$TIMESTAMP.txt${NC}"
echo ""
echo "Next steps:"
echo "1. Create resources with Account A"
echo "2. Get the resource IDs"
echo "3. Update this script with the IDs"
echo "4. Run again to test for IDOR vulnerabilities"
