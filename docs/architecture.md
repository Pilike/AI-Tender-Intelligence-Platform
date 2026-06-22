# Architecture

This document describes the sanitized architecture of the AI tender intelligence platform. Names, URLs, credentials, source-specific extraction rules, customer details, and production deployment details have been removed.

## System Goals

- Convert fragmented public tender data into normalized business opportunities.
- Reduce manual review time by summarizing long tender documents into decision-ready facts.
- Match tenders to client business profiles with explainable scoring.
- Support multiple delivery channels without tightly coupling the portal, CRM, and automations.
- Keep operational state visible in Postgres so failed automations can be retried and audited.

## High-Level Components

```mermaid
flowchart TB
    subgraph Sources
        S1[Public tender list pages]
        S2[Tender detail pages]
        S3[PDF and Office documents]
    end

    subgraph Automation
        W1[n8n source scheduler]
        W2[Fetch policy router]
        W3[Document pipeline]
        W4[Matching workflow]
        W5[Delivery workflows]
    end

    subgraph Services
        X1[HTML extractor service]
        X2[Document AI and Tika extraction]
        X3[LLM summarizer]
        X4[LLM match evaluator]
    end

    subgraph Platform
        DB[(Supabase/PostgreSQL)]
        API[ASP.NET Core portal]
        AUTH[Supabase Auth]
    end

    subgraph Delivery
        EMAIL[Email provider]
        WA[WhatsApp Cloud API]
        CRM[CRM]
    end

    S1 --> W1
    S2 --> W2
    S3 --> W3
    W2 --> X1
    W3 --> X2
    X2 --> X3
    X1 --> DB
    X3 --> DB
    API --> DB
    API --> AUTH
    DB --> W4
    W4 --> X4
    W4 --> DB
    DB --> W5
    W5 --> EMAIL
    W5 --> WA
    DB --> CRM
```

## Ingestion Flow

```mermaid
sequenceDiagram
    participant Scheduler as Source scheduler
    participant Fetch as Fetch router
    participant Extractor as Extractor service
    participant DB as Postgres
    participant Docs as Document pipeline

    Scheduler->>DB: Load sources due for crawl
    Scheduler->>Fetch: Request list/detail page
    Fetch->>Fetch: Try direct HTTP first
    Fetch->>Fetch: Escalate to rendering/proxy only when needed
    Fetch->>Extractor: Send raw HTML and source config
    Extractor->>DB: Upsert normalized tender fields
    Extractor->>DB: Record source item state and hash
    DB->>Docs: Queue document download/upload
    Docs->>DB: Upsert document metadata and extraction status
```

The ingestion layer used a cost-aware fetch policy: direct HTTP first, then escalation for sites requiring rendering or anti-bot workarounds. Extraction behavior was configuration-driven so new tender sources could be added without rewriting each workflow.

## Matching Flow

```mermaid
sequenceDiagram
    participant Admin as Admin or scheduled trigger
    participant Match as Matching workflow
    participant RPC as Postgres ranking RPC
    participant LLM as LLM evaluator
    participant DB as Postgres
    participant Delivery as Email/WhatsApp/Portal

    Admin->>Match: Run matching for client
    Match->>RPC: Rank open tenders using profile, subjects, embeddings, tier config
    RPC-->>Match: Candidate tenders
    Match->>LLM: Evaluate fit and explain recommendation
    LLM-->>Match: Score, category, reasons, risks, next steps
    Match->>DB: Upsert explainable client_matches rows
    Match->>DB: Record process metrics and rejected candidates
    DB->>Delivery: Approved matches become deliverable reports
```

The matching layer combined deterministic database filters, vector similarity, subscription-specific thresholds, and LLM evaluation. This allowed the system to keep control over candidate selection while using the LLM for reasoning and explanation.

## Event-Driven Integration

```mermaid
flowchart LR
    A[Portal action] --> B[(domain_events)]
    C[Payment callback] --> B
    D[CRM webhook] --> B
    B --> E[n8n event dispatcher]
    E --> F[CRM update]
    E --> G[WhatsApp template]
    E --> H[Email sequence]
    E --> I[(automation_runs)]
```

The portal wrote business events into Postgres instead of calling every external system directly. Automation workers consumed those events, updated external systems, and wrote execution state back into the database.

This pattern made it easier to:

- Retry failed webhooks.
- Keep a durable audit trail.
- Add new automation behavior without changing portal code.
- Separate customer-facing actions from external-service reliability.

