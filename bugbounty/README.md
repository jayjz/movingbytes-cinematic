# Bug Bounty Automation Toolkit

Automated tools for finding vulnerabilities in the Circle bug bounty program.

## 🎯 Quick Start

```bash
# 1. Set up your API keys
export CIRCLE_API_KEY="your_sandbox_api_key"
export CIRCLE_API_KEY_A="account_a_key"  # For IDOR testing
export CIRCLE_API_KEY_B="account_b_key"  # For IDOR testing

# 2. Run the API analyzer to find targets
python3 scripts/api-analyzer.py

# 3. Test for IDOR vulnerabilities
./scripts/idor-tester.sh

# 4. Test business logic flaws
./scripts/business-logic-tester.sh
```

## 📁 Tools Included

### 1. `api-analyzer.py`
Fetches OpenAPI specification and identifies potentially vulnerable endpoints.
- Finds endpoints with path parameters (IDOR candidates)
- Identifies missing authentication
- Flags sensitive operations (transfers, wallets, payments)
- Generates prioritized testing list

**Usage:**
```bash
python3 scripts/api-analyzer.py
```

**Output:** `results/api_analysis.json`

### 2. `idor-tester.sh`
Automated IDOR (Insecure Direct Object Reference) testing.
- Tests if Account B can access Account A's resources
- Tests wallets, transfers, businesses, etc.
- Generates detailed reports

**Usage:**
```bash
export CIRCLE_API_KEY_A="key_a"
export CIRCLE_API_KEY_B="key_b"
./scripts/idor-tester.sh
```

**Output:** `results/idor_test_YYYYMMDD_HHMMSS.txt`

### 3. `business-logic-tester.sh`
Tests for common fintech vulnerabilities:
- Negative amounts
- Zero amounts
- Integer overflow
- Race conditions
- Injection attacks
- Unauthorized access

**Usage:**
```bash
export CIRCLE_API_KEY="your_key"
./scripts/business-logic-tester.sh
```

**Output:** `results/business_logic_YYYYMMDD_HHMMSS.txt`

## 🎯 High-Value Targets (Circle API)

Based on the API documentation, prioritize testing:

### Critical Priority
1. **Wallet Operations**
   - `GET /v1/wallets/{id}` - IDOR to access other users' wallets
   - `POST /v1/wallets` - Create wallets with elevated privileges?
   - `GET /v1/wallets/{id}/balances` - Access other users' balances

2. **Transfers**
   - `POST /v1/transfers` - Negative amounts, zero amounts, overflow
   - `GET /v1/transfers/{id}` - Access other users' transfers
   - Race conditions on balance updates

3. **Business Accounts**
   - `GET /v1/businesses/{id}` - IDOR
   - `PUT /v1/businesses/{id}` - Modify other businesses

### Medium Priority
4. **Bank Accounts**
   - `GET /v1/banks/{id}`
   - `POST /v1/banks` - Link arbitrary bank accounts?

5. **Payments**
   - `POST /v1/payments` - Business logic flaws
   - `GET /v1/payments/{id}` - Access other payments

## 🔍 Testing Methodology

### Phase 1: Reconnaissance (30 mins)
```bash
# Discover API endpoints
python3 scripts/api-analyzer.py

# Review results
cat results/api_analysis.json | jq '.high_priority_targets[] | {method, path}'
```

### Phase 2: Authentication Testing (1 hour)
- Test all endpoints without auth token
- Test with invalid/expired tokens
- Test with malformed tokens

### Phase 3: Authorization Testing (2-3 hours)
- Create 2 test accounts
- Run IDOR tester on all endpoints with IDs
- Document any access control bypasses

### Phase 4: Business Logic (2-3 hours)
- Test negative/zero amounts
- Test race conditions (send 10 requests simultaneously)
- Test boundary values (max int, etc.)

### Phase 5: Edge Cases (1 hour)
- Special characters in all fields
- Very long strings
- Null bytes, unicode, etc.

## 📊 Expected Results

Based on typical fintech APIs, you should find:
- **2-3 IDORs** (medium severity, $400-800 each)
- **1-2 business logic issues** (medium-high, $800-2,400)
- **Several low-severity issues** (info disclosure, etc., $150-400)

**Conservative estimate:** 3-5 bugs = $1,500 - $4,000

## 🚨 Important Notes

1. **Only test on sandbox!** `api-sandbox.circle.com`, NOT production
2. **Use test accounts only** - Don't touch real user data
3. **Rate limit your tests** - Don't DoS the sandbox
4. **Document everything** - HackerOne needs reproduction steps
5. **One bug per report** - Don't bundle multiple issues

## 📝 Reporting Template

When you find a bug, use this format:

```markdown
**Summary:**
[One line description]

**Steps to Reproduce:**
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Expected Behavior:**
[What should happen]

**Actual Behavior:**
[What actually happens]

**Impact:**
[Why this matters - data exposure, financial loss, etc.]

**Proof of Concept:**
```bash
[Exact curl commands or screenshots]
```

**Remediation:**
[How to fix it]
```

## 🔧 Customization

Edit the scripts to add:
- Your specific test cases
- Additional endpoints
- Custom payloads
- Integration with your reporting workflow

## 📈 Next Steps

1. Run the tools against the sandbox
2. Review results for potential vulnerabilities
3. Manually verify findings
4. Write detailed reports
5. Submit to HackerOne
6. Get paid! 💰

---

**Happy hunting! Remember: Quality over quantity. One well-documented critical bug beats ten low-effort reports.**
