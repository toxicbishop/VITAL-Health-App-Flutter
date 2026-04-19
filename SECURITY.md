# Security Policy

## Supported Versions

| Version | Supported              |
| ------- | ---------------------- |
| 2.4.x   | ✅ Active support      |
| < 2.4   | ❌ No longer supported |

## Reporting a Vulnerability

If you discover a security vulnerability in VITAL Health App, please report it responsibly.

**Do NOT open a public GitHub issue for security vulnerabilities.**

Instead, please email: **[pranavarun19@gmail.com]**

Include the following in your report:

- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if applicable)

We aim to acknowledge reports within **48 hours** and provide a fix within **7 days** for critical issues.

## Security Practices

### Data Storage

- All health data is stored **locally** on the device using SQLite (Floor ORM).
- No health data is transmitted to external servers unless the user explicitly initiates a Google Sheets sync.
- `android:allowBackup="false"` prevents ADB backup of app data.
- `android:usesCleartextTraffic="false"` enforces HTTPS for all network traffic.

### Authentication & Secrets

- Google OAuth Client ID is injected at build time via `--dart-define` and never hardcoded in source.
- No API keys, tokens, or passwords exist in the codebase.
- CI/CD secrets are stored in GitHub Actions encrypted secrets.

### Input Validation

- All health metric inputs are validated against physiologically plausible ranges before storage.
- Mood values are restricted to a predefined allowlist.

### CI/CD Security

- Automated secret scanning runs on every push and pull request.
- Static analysis (`flutter analyze`) enforced on all code changes.
- Dependencies are pinned to exact versions to prevent supply-chain attacks.

## Scope

The following are **in scope** for security reports:

- Data leakage or unauthorized access to health records
- Hardcoded credentials or secrets
- Injection vulnerabilities (SQL, etc.)
- Insecure data transmission
- Authentication/authorization bypasses

The following are **out of scope**:

- Denial of service on the local device
- Physical access attacks (rooted/jailbroken devices)
- Social engineering
