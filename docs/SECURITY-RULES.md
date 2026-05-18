# Security Rules

Applies whenever editing `.env*` files or files under `**/api/**`. In Claude Code, these rules auto-inject for matching paths via `.claude/rules/security.md`. In opencode, they are loaded every session via the `instructions` entry in `opencode.json`.

## Secrets Management
- NEVER commit secrets, API keys, or credentials to git
- Use `.env.local` (or equivalent) for local development — keep it in `.gitignore`
- Document all required env vars in `.env.local.example` with dummy values

## Input Validation
- Never trust client-side validation alone
- Sanitize data before database insertion / external command execution

## Authentication
- Always verify authentication before processing API requests
- Implement rate limiting on authentication endpoints

## Security Headers
- X-Frame-Options: DENY
- X-Content-Type-Options: nosniff
- Referrer-Policy: origin-when-cross-origin
- Strict-Transport-Security with includeSubDomains

## Code Review Triggers
- Any changes to authentication flow require explicit user approval
- Any new environment variables must be documented in `.env.local.example`
