# Workflow Design

The production implementation used n8n for orchestration across crawler jobs, document pipelines, matching runs, CRM sync, WhatsApp, and email delivery. Raw workflow exports are intentionally not included because they can expose proprietary logic, webhook paths, credential names, production URLs, and business-specific implementation details.

The files in [../examples/workflows](../examples/workflows) are safe skeletons that document the shape of the automations without exposing importable production workflows.

## Main Workflow Families

| Workflow family | Purpose | Key design points |
| --- | --- | --- |
| Tender source crawling | Discover tender list/detail pages and normalize them into canonical records. | Config-driven source patterns, direct-fetch-first policy, source run tracking, hash-based change detection. |
| Document upload | Download tender documents and store normalized metadata. | Durable document status, retry fields, storage keys, extraction readiness flags. |
| Document AI and summaries | Convert PDFs/Office files into structured business intelligence. | Multi-stage extraction, LLM summarization, schema-safe JSON normalization, stale summary refresh. |
| Client profile generation | Turn onboarding answers and CRM details into matching profiles. | Profile prompt, activity domains, service roles, exclusion rules, matching preferences. |
| Hybrid matching | Rank open tenders and run LLM fit evaluation. | PostgreSQL RPC candidate selection, vector similarity, subscription thresholds, deduplication, explainable results. |
| Delivery | Send approved matches through email, portal, and WhatsApp. | Approval flags, delivery tracking, channel-specific templates, retry behavior. |
| CRM and onboarding | Sync account state, opportunities, payment/onboarding events, and user creation. | Domain events, CRM identity map, idempotent updates, token-based onboarding. |
| WhatsApp assistant | Handle inbound messages, templates, session state, and status callbacks. | Webhook verification, message history, AI response routing, template delivery. |

## Example: Tender Ingestion

```text
schedule/run trigger
  -> load due tender sources
  -> fetch list page
  -> extract candidate links
  -> fetch detail pages with cost-aware policy
  -> call extractor service with raw HTML and source config
  -> validate normalized fields
  -> upsert tender and source item records
  -> queue documents for download/extraction
```

## Example: Matching

```text
admin/scheduled trigger
  -> load client profile and subscription config
  -> call ranking RPC for candidate tenders
  -> run LLM prefilter or full evaluation
  -> normalize score, fit category, risks, and explanation bullets
  -> upsert client_matches
  -> record run counters and rejected candidates
  -> mark approved matches for delivery
```

## Example: Event-Driven CRM/WhatsApp

```text
portal action or payment callback
  -> insert domain event
  -> automation worker leases queued event
  -> resolve CRM identity map
  -> send CRM update, WhatsApp template, or email
  -> write automation_run result
  -> retry failures according to config
```

## Why Workflows Were Not Published Raw

Raw workflow exports often include:

- Webhook UUIDs and endpoint paths.
- Credential names and service identifiers.
- Internal table names and private business logic.
- CRM stage IDs, template names, and source-specific extraction strategies.
- Enough detail to clone the employer's operational system.

For hiring purposes, the useful signal is the architecture, control flow, data model, and integration reasoning. Those are preserved here without exposing production material.

