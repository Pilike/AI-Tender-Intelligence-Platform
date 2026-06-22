# Improvement Roadmap

This is a practical hardening and portfolio backlog based on reviewing the original project. It separates what should be done privately in the production codebase from what is useful to add publicly for hiring.

## Private Production Hardening

1. **Rotate exposed credentials.** Rotate any Supabase, database, Google, CRM, WhatsApp, payment, LLM, and webhook credentials that appeared in source-controlled config or scripts.
2. **Move secrets out of appsettings.** Use environment variables, managed secret storage, or deployment-level secret injection for all sensitive values.
3. **Add automated secret scanning.** Use pre-commit hooks and CI checks such as Gitleaks or GitHub secret scanning before any push.
4. **Split oversized controllers.** Move admin actions, WhatsApp operations, matching triggers, and CRM/payment flows into focused services and smaller controllers.
5. **Centralize integration options.** Use typed configuration classes with startup validation so missing webhook URLs or API keys fail clearly.
6. **Formalize workflow promotion.** Keep production workflow exports outside the public repo and version redacted workflow docs or generated summaries.
7. **Increase integration test coverage.** Prioritize payment callbacks, onboarding tokens, CRM sync idempotency, match upserts, and WhatsApp delivery status handling.
8. **Add observability conventions.** Standardize correlation IDs across portal requests, domain events, automation runs, and external webhook calls.
9. **Review RLS and database permissions.** Ensure portal roles, service roles, admin actions, and public token access paths are intentionally separated.
10. **Document recovery playbooks.** Add runbooks for failed crawler runs, failed document extraction, stuck automations, duplicate CRM records, and WhatsApp delivery failures.

## Public Portfolio Improvements

1. **Add sanitized screenshots.** Use redacted or recreated screenshots of the match dashboard, client profile, and workflow monitoring views.
2. **Add an architecture image.** Export the Mermaid architecture to PNG for recruiters who skim quickly.
3. **Add a short demo video.** Record a 60-90 second walkthrough of the sanitized diagrams and data model, without showing production systems.
4. **Add a fake sample dataset.** Include 3-5 synthetic tenders and 2 synthetic client profiles to explain how matching works.
5. **Add a runnable mini-demo later.** A small local-only demo could show candidate ranking and match explanation with fake data.
6. **Add Cloud Run sample contracts.** Publish sanitized request/response contracts for the extractor service instead of the production function.
7. **Add Make/n8n examples as separate projects.** Smaller automation projects can become separate GitHub repos if they show clear business outcomes.

## About The GCP Cloud Run Functions

The raw Cloud Run functions should not be published if they contain production extraction logic, service URLs, source-specific patterns, or employer-owned implementation details.

The best public version is a sanitized service contract plus a small example handler that shows the shape of the integration:

- request receives `sourceId`, `sourceUrl`, raw HTML, and extraction hints;
- response returns normalized tender fields, document links, confidence, and errors;
- no production source rules, endpoints, credentials, or anti-bot details are included.

