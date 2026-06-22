# Workflow Design

This document describes the workflow families that made the platform useful in production.

## Workflow Families

| Workflow family | Purpose | Key design points |
| --- | --- | --- |
| Discovery | Find and collect public opportunity information. | Reliability, source variability, change detection, and controlled cost. |
| Document processing | Convert long documents into decision-ready facts. | Extraction quality, summary consistency, and reviewability. |
| Client profiling | Translate a business profile into matching criteria. | Business-language inputs, clear exclusions, and maintainable settings. |
| Matching | Decide whether an opportunity is relevant enough to review. | Explainability, ranking quality, and avoiding noisy alerts. |
| Delivery | Send approved opportunities to users. | Clear formatting, channel fit, delivery tracking, and retry handling. |
| Operations | Help admins see what ran, what failed, and what needs attention. | Support visibility, manual review paths, and exception handling. |

## Design Principles

- Keep discovery, document processing, matching, delivery, and support as separate concerns.
- Prefer structured AI outputs that can be reviewed, explained, and improved over opaque text blobs.
- Treat failed external calls and ambiguous documents as expected operational cases, not surprises.
- Connect automation to business outcomes: fewer missed opportunities, faster review, and clearer next steps.
