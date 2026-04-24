#!/bin/bash
# Bug Bounty Orchestrator
# Master script to run all security tests

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULTS_DIR="$SCRIPT_DIR/../results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
MASTER_LOG="$RESULTS_DIR/orchestrator_$TIMESTAMP.log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Logging
log() {
    echo -e "$1" | tee -a "$MASTER_LOG"
}

log_header() {
    echo "" | tee -a "$MASTER_LOG"
    echo "========================================" | tee -a "$MASTER_LOG"
    echo "$1" | tee -a "$MASTER_LOG"
    echo "========================================" | tee -a "$MASTER_LOG"
}

# Banner
clear
cat << "EOF"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║           🐛 BUG BOUNTY ORCHESTRATOR v1.0 🐛                ║
║                                                              ║
║  Automated Security Testing for Bug Bounty Programs        ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
EOF

log "\n${BLUE}Starting bug bounty automation suite...${NC}"
log "Timestamp: $(date)"
log "Results directory: $RESULTS_DIR"
log "Master log: $MASTER_LOG"

# Check environment
log_header "ENVIRONMENT CHECK"

# Check for required tools
tools=("curl" "python3" "bash")
missing_tools=()

for tool in "${tools[@]}"; do
    if command -v "$tool" &> /dev/null; then
        log "${GREEN}✓${NC} $tool found"
    else
        log "${RED}✗${NC} $tool NOT found"
        missing_tools+=("$tool")
    fi
done

if [ ${#missing_tools[@]} -ne 0 ]; then
    log "${RED}Missing required tools: ${missing_tools[*]}${NC}"
    exit 1
fi

# Check for API keys
log "\n${BLUE}Checking for API keys...${NC}"

if [ -n "$CIRCLE_API_KEY" ]; then
    log "${GREEN}✓${NC} CIRCLE_API_KEY is set"
else
    log "${YELLOW}⚠${NC} CIRCLE_API_KEY not set (Circle tests will be skipped)"
fi

if [ -n "$CIRCLE_API_KEY_A" ] && [ -n "$CIRCLE_API_KEY_B" ]; then
    log "${GREEN}✓${NC} CIRCLE_API_KEY_A and CIRCLE_API_KEY_B are set (IDOR tests enabled)"
else
    log "${YELLOW}⚠${NC} Circle API key pair not set (IDOR tests will be skipped)"
fi

# Menu
log_header "SELECT TEST SUITE"

echo ""
echo "Available test suites:"
echo "1) Circle API - Full test suite (requires API keys)"
echo "2) Circle API - Recon only (no keys required)"
echo "3) Custom target (provide URL)"
echo "4) Install additional tools"
echo "5) View previous results"
echo "6) Exit"
echo ""

read -p "Select option [1-6]: " choice

case $choice in
    1)
        log_header "RUNNING CIRCLE API FULL SUITE"
        
        if [ -z "$CIRCLE_API_KEY" ]; then
            log "${RED}Error: CIRCLE_API_KEY not set${NC}"
            log "Run: export CIRCLE_API_KEY='your_key'"
            exit 1
        fi
        
        log "\n${YELLOW}[1/4] Running API structure analysis...${NC}"
        python3 "$SCRIPT_DIR/api-analyzer.py" 2>&1 | tee -a "$MASTER_LOG"
        
        if [ -n "$CIRCLE_API_KEY_A" ] && [ -n "$CIRCLE_API_KEY_B" ]; then
            log "\n${YELLOW}[2/4] Running IDOR tests...${NC}"
            bash "$SCRIPT_DIR/idor-tester.sh" 2>&1 | tee -a "$MASTER_LOG"
        else
            log "\n${YELLOW}[2/4] Skipping IDOR tests (API keys not configured)${NC}"
        fi
        
        log "\n${YELLOW}[3/4] Running business logic tests...${NC}"
        bash "$SCRIPT_DIR/business-logic-tester.sh" 2>&1 | tee -a "$MASTER_LOG"
        
        log "\n${YELLOW}[4/4] Checking for common vulnerabilities...${NC}"
        # Add more tests here as they're developed
        
        log "\n${GREEN}✓ Full test suite complete!${NC}"
        ;;
        
    2)
        log_header "RUNNING RECONNAISSANCE ONLY"
        log "\n${YELLOW}Running API analyzer (no auth required)...${NC}"
        python3 "$SCRIPT_DIR/api-analyzer.py" 2>&1 | tee -a "$MASTER_LOG"
        log "\n${GREEN}✓ Reconnaissance complete!${NC}"
        ;;
        
    3)
        log_header "CUSTOM TARGET"
        read -p "Enter target URL: " target_url
        log "Target: $target_url"
        log "${YELLOW}Custom target testing not yet implemented${NC}"
        log "You can manually test with:"
        log "  curl -s $target_url"
        ;;
        
    4)
        log_header "INSTALLING ADDITIONAL TOOLS"
        log "This would install: nuclei, ffuf, subfinder, httpx, etc."
        log "${YELLOW}Manual installation required (no sudo access in this environment)${NC}"
        log ""
        log "To install manually:"
        log "  wget https://github.com/projectdiscovery/nuclei/releases/latest/download/nuclei_linux_amd64.zip"
        log "  unzip nuclei_linux_amd64.zip && sudo mv nuclei /usr/local/bin/"
        ;;
        
    5)
        log_header "PREVIOUS RESULTS"
        if [ -d "$RESULTS_DIR" ] && [ "$(ls -A $RESULTS_DIR)" ]; then
            log "Recent test results:"
            ls -lt "$RESULTS_DIR" | head -20
            echo ""
            read -p "Enter filename to view (or press Enter to skip): " filename
            if [ -n "$filename" ] && [ -f "$RESULTS_DIR/$filename" ]; then
                cat "$RESULTS_DIR/$filename"
            fi
        else
            log "No previous results found."
        fi
        ;;
        
    6)
        log "Exiting..."
        exit 0
        ;;
        
    *)
        log "${RED}Invalid option${NC}"
        exit 1
        ;;
esac

# Summary
log_header "TEST SUMMARY"
log "Completed at: $(date)"
log "Results saved to: $RESULTS_DIR"
log ""
log "Next steps:"
log "1. Review results in $RESULTS_DIR"
log "2. Investigate any findings"
log "3. Reproduce vulnerabilities manually"
log "4. Document with screenshots"
log "5. Submit to HackerOne"
log ""
log "${GREEN}Happy hunting! 🐛💰${NC}"
