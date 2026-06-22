# Security And Sanitization

This repository was created from a security-first review of the original project. The original repository should not be published publicly as-is.

## Removed From The Public Version

- Original git history.
- Production app settings and development settings.
- Supabase URLs, anon keys, service keys, database passwords, JWTs, and project references.
- Google OAuth, Google Ads, Document AI, and Cloud Run identifiers.
- WhatsApp Business account IDs, phone IDs, access tokens, template webhook URLs, and callback paths.
- CRM API tokens, CRM object IDs, stage IDs, and customer-linked records.
- Payment provider credentials and callback URLs.
- OpenAI/OpenRouter/LLM provider keys.
- Raw n8n and Make workflow exports.
- Azure DevOps pipeline identifiers and production cloud deployment details.
- Real customer records, phone numbers, emails, tender-source internals, and source-specific extraction patterns.
- Build outputs, test results, local IDE state, and assistant files.

## Sanitization Strategy

1. **New repository, no history:** the public repo is a clean case-study repo, not a filtered copy of the employer repository.
2. **Docs over raw exports:** architecture and workflow behavior are described in sanitized prose and diagrams.
3. **Representative SQL only:** schema examples show modeling choices without the full production migration history.
4. **Small code samples only:** code snippets are recreated as representative examples, not copied wholesale from production.
5. **Placeholders only:** all identifiers use placeholder names such as `example.com`, `CLIENT_ID`, and `WEBHOOK_URL`.
6. **No runnable production clone:** the repo demonstrates skill without enabling someone to recreate the live system.

## Credential Rotation Recommendation

During the original-project audit, live-looking credentials and production endpoints were found in configuration files and helper scripts. Those values should be rotated in the source systems before any public sharing, even though they are not included here.

Recommended rotations:

- Supabase service keys, anon keys, database password, and JWT signing-related keys if exposed.
- Google OAuth refresh tokens, client secrets, Google Ads developer token, and service account credentials.
- WhatsApp Cloud API tokens and webhook verification secrets.
- CRM API tokens.
- Payment provider private tokens and test credentials.
- LLM provider API keys.
- n8n webhook URLs or workflow IDs if they should not be externally discoverable.

## Public Sharing Guidance

This repo is suitable for a GitHub portfolio because it shows system design, data modeling, integration patterns, and AI automation work without disclosing the employer's sensitive implementation.

If a recruiter or interviewer wants deeper detail, discuss architecture, tradeoffs, and lessons learned live rather than publishing the raw source.

