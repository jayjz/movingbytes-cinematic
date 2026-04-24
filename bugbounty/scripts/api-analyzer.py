#!/usr/bin/env python3
"""
Circle API Analyzer
Fetches API documentation and identifies potentially vulnerable endpoints
"""

import json
import urllib.request
import ssl
import sys
from urllib.error import URLError

# Disable SSL verification for sandbox (if needed)
ssl._create_default_https_context = ssl._create_unverified_context

API_DOCS_URL = "https://api-sandbox.circle.com/.well-known/openapi.json"
RESULTS_FILE = "/home/ubuntu/.openclaw/workspace/bugbounty/results/api_analysis.json"

def fetch_api_spec():
    """Fetch OpenAPI specification"""
    try:
        print(f"[*] Fetching API spec from {API_DOCS_URL}")
        with urllib.request.urlopen(API_DOCS_URL, timeout=10) as response:
            data = response.read().decode('utf-8')
            return json.loads(data)
    except URLError as e:
        print(f"[!] Failed to fetch API spec: {e}")
        print("[*] Trying alternative endpoints...")
        
        # Try common OpenAPI locations
        alternatives = [
            "https://api-sandbox.circle.com/openapi.json",
            "https://api-sandbox.circle.com/swagger.json",
            "https://api-sandbox.circle.com/v1/openapi.json",
        ]
        
        for url in alternatives:
            try:
                print(f"[*] Trying {url}")
                with urllib.request.urlopen(url, timeout=10) as response:
                    data = response.read().decode('utf-8')
                    return json.loads(data)
            except:
                continue
        
        return None
    except Exception as e:
        print(f"[!] Error: {e}")
        return None

def analyze_endpoints(spec):
    """Analyze API endpoints for potential vulnerabilities"""
    if not spec or 'paths' not in spec:
        print("[!] No paths found in API spec")
        return []
    
    vulnerable_endpoints = []
    paths = spec['paths']
    
    print(f"\n[*] Analyzing {len(paths)} endpoints...")
    
    for path, methods in paths.items():
        for method, details in methods.items():
            if method.upper() not in ['GET', 'POST', 'PUT', 'DELETE', 'PATCH']:
                continue
            
            endpoint_info = {
                'path': path,
                'method': method.upper(),
                'summary': details.get('summary', ''),
                'vulnerabilities': []
            }
            
            # Check for potential IDOR (paths with IDs)
            if '{' in path and '}' in path:
                endpoint_info['vulnerabilities'].append({
                    'type': 'Potential IDOR',
                    'severity': 'High',
                    'description': 'Endpoint uses path parameters that could be manipulated',
                    'test': f'Try accessing other users\' resources by changing the ID'
                })
            
            # Check for missing auth (if specified in spec)
            security = details.get('security', [])
            if not security:
                endpoint_info['vulnerabilities'].append({
                    'type': 'Missing Authentication',
                    'severity': 'Critical',
                    'description': 'Endpoint may not require authentication',
                    'test': 'Try accessing without Authorization header'
                })
            
            # Check for sensitive operations
            sensitive_keywords = ['transfer', 'withdraw', 'delete', 'admin', 'config', 'key', 'secret', 'wallet', 'payment']
            path_lower = path.lower()
            summary_lower = endpoint_info['summary'].lower()
            
            for keyword in sensitive_keywords:
                if keyword in path_lower or keyword in summary_lower:
                    endpoint_info['vulnerabilities'].append({
                        'type': 'Sensitive Operation',
                        'severity': 'Medium',
                        'description': f'Endpoint involves {keyword} - test for auth bypass and business logic flaws',
                        'test': f'Test authorization, input validation, and business logic for {keyword} operations'
                    })
                    break
            
            # Check parameters for injection points
            parameters = details.get('parameters', [])
            for param in parameters:
                param_in = param.get('in', '')
                param_name = param.get('name', '')
                
                if param_in in ['query', 'path']:
                    # Potential for injection or manipulation
                    if any(x in param_name.lower() for x in ['id', 'user', 'account', 'wallet']):
                        endpoint_info['vulnerabilities'].append({
                            'type': 'User-Controlled Identifier',
                            'severity': 'High',
                            'description': f'Parameter "{param_name}" may be vulnerable to IDOR',
                            'test': f'Manipulate {param_name} to access other users\' data'
                        })
            
            if endpoint_info['vulnerabilities']:
                vulnerable_endpoints.append(endpoint_info)
    
    return vulnerable_endpoints

def generate_report(endpoints):
    """Generate a report of potentially vulnerable endpoints"""
    report = {
        'total_endpoints_analyzed': len(endpoints),
        'high_priority_targets': [],
        'medium_priority_targets': [],
        'low_priority_targets': []
    }
    
    for endpoint in endpoints:
        # Categorize by highest severity
        severities = [v['severity'] for v in endpoint['vulnerabilities']]
        
        if 'Critical' in severities or 'High' in severities:
            report['high_priority_targets'].append(endpoint)
        elif 'Medium' in severities:
            report['medium_priority_targets'].append(endpoint)
        else:
            report['low_priority_targets'].append(endpoint)
    
    return report

def main():
    print("=" * 60)
    print("Circle API Security Analyzer")
    print("=" * 60)
    
    # Fetch API spec
    spec = fetch_api_spec()
    
    if not spec:
        print("\n[!] Could not fetch API specification")
        print("[*] Creating manual analysis template...")
        
        # Create a template for manual analysis
        manual_template = {
            "note": "API spec not accessible - manual testing required",
            "common_endpoints_to_test": [
                "/v1/wallets",
                "/v1/wallets/{id}",
                "/v1/transfers",
                "/v1/transfers/{id}",
                "/v1/businesses",
                "/v1/businesses/{id}",
                "/v1/banks",
                "/v1/banks/{id}",
                "/v1/payments",
                "/v1/payments/{id}",
                "/v1/chargebacks",
                "/v1/settlements"
            ],
            "test_cases": [
                "IDOR: Access other user's wallets",
                "IDOR: Access other user's transfers",
                "BOLA: Modify other user's resources",
                "Missing auth on sensitive endpoints",
                "Business logic: Negative amounts",
                "Business logic: Duplicate transfers",
                "Rate limiting bypass"
            ]
        }
        
        with open(RESULTS_FILE, 'w') as f:
            json.dump(manual_template, f, indent=2)
        
        print(f"[*] Manual template saved to: {RESULTS_FILE}")
        return
    
    # Analyze endpoints
    vulnerable_endpoints = analyze_endpoints(spec)
    
    # Generate report
    report = generate_report(vulnerable_endpoints)
    
    # Save results
    with open(RESULTS_FILE, 'w') as f:
        json.dump(report, f, indent=2)
    
    # Print summary
    print("\n" + "=" * 60)
    print("ANALYSIS COMPLETE")
    print("=" * 60)
    print(f"Total endpoints with potential issues: {len(vulnerable_endpoints)}")
    print(f"High priority: {len(report['high_priority_targets'])}")
    print(f"Medium priority: {len(report['medium_priority_targets'])}")
    print(f"Low priority: {len(report['low_priority_targets'])}")
    print(f"\nDetailed report saved to: {RESULTS_FILE}")
    
    # Print high-priority targets
    if report['high_priority_targets']:
        print("\n" + "=" * 60)
        print("HIGH PRIORITY TARGETS (Test These First):")
        print("=" * 60)
        for target in report['high_priority_targets'][:10]:  # Top 10
            print(f"\n{target['method']} {target['path']}")
            print(f"  Summary: {target['summary']}")
            for vuln in target['vulnerabilities']:
                if vuln['severity'] in ['Critical', 'High']:
                    print(f"  [!] {vuln['type']}: {vuln['description']}")

if __name__ == '__main__':
    main()
