# Portfolio Copy

## GitHub Description

Sanitized case study of an AI tender intelligence platform: crawler workflows, document AI, LLM summaries, vector matching, Supabase/PostgreSQL, n8n, ASP.NET Core, CRM, email, and WhatsApp delivery.

## Project Summary

Built a production AI procurement intelligence platform that automated the full lifecycle from tender discovery to analysis, client matching, and delivery. The platform helped service providers decide which public tenders were worth pursuing by combining web crawling, document AI, LLM summarization, structured data extraction, vector matching, client profiles, and multi-channel delivery.

## Resume Bullets

- Architected an AI tender intelligence platform spanning ASP.NET Core, Supabase/PostgreSQL, n8n, GCP, Docker, WhatsApp Cloud API, CRM integration, email delivery, and LLM APIs.
- Built crawler and document pipelines for public tender discovery, HTML extraction, document upload, AI summarization, structured field extraction, retry tracking, and canonical tender upserts.
- Designed a PostgreSQL data model for clients, tenders, documents, matches, WhatsApp sessions, onboarding state, automation configs, domain events, and CRM identity mapping.
- Implemented a hybrid matching engine using PostgreSQL RPC functions, vector similarity, subscription-aware thresholds, service-role logic, LLM evaluation, deduplication, and explainable match output.
- Delivered client-facing reports through portal views, email, WhatsApp notifications, and CRM-driven onboarding workflows.

## Interview Talking Points

- Why the system used Postgres as both application database and automation control plane.
- How cost-aware crawling reduced unnecessary expensive fetches.
- Why deterministic database ranking came before LLM evaluation.
- How match explanations were stored for auditability and client trust.
- How domain events reduced coupling between portal actions, CRM updates, WhatsApp templates, and payment/onboarding flows.
- What had to be sanitized before sharing publicly.

