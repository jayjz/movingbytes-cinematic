# Bug Bounty Testing Environment

## Environment Status: ✅ READY

This environment is configured for authorized security testing of bug bounty targets.

### Installed Tools
- ✅ Python 3 (for custom scripts)
- ✅ curl/wget (for HTTP testing)
- ✅ git (for cloning repos)
- ✅ bash (scripting)
- ⚠️  nuclei, ffuf, go tools (require manual install - see below)

### Directory Structure
```
/home/ubuntu/.openclaw/workspace/bugbounty/
├── scripts/           # Automation scripts
│   ├── api-analyzer.py
│   ├── idor-tester.sh
│   └── business-logic-tester.sh
├── results/           # Test results and findings
├── targets/           # Target configurations
└── ENVIRONMENT_SETUP.md (this file)
```

## 🚀 Quick Start

### 1. Set Up API Keys

```bash
# For Circle API testing
export CIRCLE_API_KEY="your_sandbox_key"
export CIRCLE_API_KEY_A="account_a_key"
export CIRCLE_API_KEY_B="account_b_key"

# For Crypto.com (when ready)
export CRYPTO_API_KEY="your_key"
```

### 2. Install Additional Tools (Optional)

```bash
# Nuclei (vulnerability scanner)
wget https://github.com/projectdiscovery/nuclei/releases/download/v3.1.0/nuclei_3.1.0_linux_amd64.zip
unzip nuclei_3.1.0_linux_amd64.zip
sudo mv nuclei /usr/local/bin/

# FFuF (web fuzzer)
wget https://github.com/ffuf/ffuf/releases/download/v2.1.0/ffuf_2.1.0_linux_amd64.tar.gz
tar -xzf ffuf_2.1.0_linux_amd64.tar.gz
sudo mv ffuf /usr/local/bin/

# Update nuclei templates
nuclei -update-templates
```

### 3. Run Tests

```bash
cd /home/ubuntu/.openclaw/workspace/bugbounty

# Analyze API structure
python3 scripts/api-analyzer.py

# Test for IDOR vulnerabilities
./scripts/idor-tester.sh

# Test business logic flaws
./scripts/business-logic-tester.sh
```

## 🎯 Current Targets Configured

### Circle (Sandbox)
- **API:** https://api-sandbox.circle.com
- **App:** https://app-sandbox.circle.com
- **Status:** ⏳ Waiting for API keys
- **Tools ready:** ✅

### Crypto.com
- **API:** https://api.crypto.com
- **Exchange:** https://crypto.com/exchange
- **Status:** ⏳ Waiting for account setup
- **Tools ready:** ⚠️ Need custom scripts

## 📋 Testing Checklist

### Before You Start:
- [ ] Read the program scope carefully
- [ ] Set up test accounts (with _h1 suffix where required)
- [ ] Get API keys
- [ ] Understand the rules of engagement
- [ ] Set up Burp Suite or similar proxy (optional but recommended)

### During Testing:
- [ ] Test on SANDBOX only (never production)
- [ ] Document every step
- [ ] Save all requests/responses
- [ ] Take screenshots
- [ ] Note timestamps

### After Finding a Bug:
- [ ] Reproduce 3x to confirm
- [ ] Document exact reproduction steps
- [ ] Assess impact
- [ ] Check for duplicates
- [ ] Write clear report
- [ ] Submit via HackerOne

## 🛡️ Rules of Engagement

**ALWAYS:**
- ✅ Test only in-scope targets
- ✅ Use your own test accounts
- ✅ Follow rate limits
- ✅ Document everything
- ✅ Report responsibly

**NEVER:**
- ❌ Test production systems
- ❌ Access other users' data (unless testing IDOR with your own accounts)
- ❌ Perform DoS attacks
- ❌ Exfiltrate data
- ❌ Publicly disclose before patch

## 📊 Results Tracking

All test results are saved to:
```
/home/ubuntu/.openclaw/workspace/bugbounty/results/
```

Format: `{test_type}_{YYYYMMDD}_{HHMMSS}.txt`

Review results after each test run:
```bash
ls -lt results/ | head -10
cat results/[latest-file].txt
```

## 🔧 Customization

Edit scripts to add:
- Your specific test cases
- Custom payloads
- Additional endpoints
- Integration with other tools

## 📚 Next Steps

1. **Get API keys** for your target
2. **Run initial reconnaissance**
3. **Identify high-value targets**
4. **Execute targeted tests**
5. **Document findings**
6. **Submit reports**

---

**Environment ready. Awaiting API keys and target selection.**
