# Workflow Design

This document describes workflow families at a public-safe level. It intentionally excludes raw workflow exports, node logic, webhook paths, credential names, table names, prompts, exact branching, source-specific extraction logic, and any details that would allow the original system to be recreated.

## Workflow Families

| Workflow family | Purpose | Key design points |
| --- | --- | --- |
| Discovery | Find and collect public opportunity information. | Reliability, source variability, change detection, and controlled cost. |
| Document processing | Convert long documents into decision-ready facts. | Extraction quality, summary consistency, and reviewability. |
| Client profiling | Translate a business profile into matching criteria. | Business-language inputs, clear exclusions, and maintainable settings. |
| Matching | Decide whether an opportunity is relevant enough to review. | Explainability, ranking quality, and avoiding noisy alerts. |
| Delivery | Send approved opportunities to users. | Clear formatting, channel fit, delivery tracking, and retry handling. |
| Operations | Help admins see what ran, what failed, and what needs attention. | Support visibility, manual review paths, and exception handling. |

## Why Workflows Were Not Published Raw

Raw workflow exports often include:

- Webhook UUIDs and endpoint paths.
- Credential names and service identifiers.
- Internal table names and private business logic.
- External-system IDs, template names, and source-specific extraction strategies.
- Enough detail to clone the employer's operational system.

For hiring purposes, the useful signal is the ability to understand a business process and design reliable automation around it. That signal is preserved here without publishing implementation material.
