-- Sanitized representative schema excerpt for an AI tender intelligence platform.
-- This is not the production schema.

create extension if not exists pgcrypto;
create extension if not exists vector;

create type subscription_tier as enum ('trial', 'standard', 'premium');
create type tender_status as enum ('open', 'closed', 'unknown');
create type match_fit_category as enum ('direct_match', 'business_opportunity', 'not_recommended');
create type automation_run_status as enum ('queued', 'running', 'succeeded', 'failed', 'dead_letter');

create table clients (
    id uuid primary key default gen_random_uuid(),
    company_name text not null,
    contact_email text,
    subscription subscription_tier not null default 'trial',
    is_active boolean not null default true,
    onboarding_state text not null default 'new',
    public_matches_token uuid not null default gen_random_uuid(),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table client_profiles (
    id uuid primary key default gen_random_uuid(),
    client_id uuid not null references clients(id) on delete cascade,
    profile_prompt text not null,
    service_roles text[] not null default '{}',
    activity_domains text[] not null default '{}',
    exclusion_terms text[] not null default '{}',
    embedding vector(1536),
    profile_version integer not null default 1,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table tender_sources (
    id uuid primary key default gen_random_uuid(),
    source_name text not null,
    base_url text not null,
    source_type text not null default 'public_site',
    fetch_policy jsonb not null default '{}'::jsonb,
    extraction_config jsonb not null default '{}'::jsonb,
    last_run_at timestamptz,
    is_active boolean not null default true,
    created_at timestamptz not null default now()
);

create table tenders (
    id uuid primary key default gen_random_uuid(),
    source_id uuid references tender_sources(id),
    source_item_key text,
    title text not null,
    buyer_name text,
    source_url text,
    status tender_status not null default 'unknown',
    publish_date date,
    deadline_at timestamptz,
    estimated_value numeric(14,2),
    raw_payload jsonb not null default '{}'::jsonb,
    normalized_payload jsonb not null default '{}'::jsonb,
    needs_resummary boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    unique (source_id, source_item_key)
);

create table tender_documents (
    id uuid primary key default gen_random_uuid(),
    tender_id uuid not null references tenders(id) on delete cascade,
    source_url text,
    storage_key text,
    file_name text,
    content_type text,
    extraction_status text not null default 'pending',
    text_hash text,
    extracted_text text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table tender_document_summaries (
    id uuid primary key default gen_random_uuid(),
    tender_document_id uuid not null references tender_documents(id) on delete cascade,
    summary text not null,
    requirements jsonb not null default '[]'::jsonb,
    certifications jsonb not null default '[]'::jsonb,
    deadlines jsonb not null default '[]'::jsonb,
    financial_terms jsonb not null default '[]'::jsonb,
    risk_notes jsonb not null default '[]'::jsonb,
    model_name text,
    created_at timestamptz not null default now()
);

create table tender_embeddings (
    tender_id uuid primary key references tenders(id) on delete cascade,
    embedding vector(1536) not null,
    embedding_text text not null,
    model_name text not null,
    created_at timestamptz not null default now()
);

create table subscription_matching_config (
    subscription subscription_tier primary key,
    min_vector_score numeric(5,4) not null,
    max_candidates integer not null,
    allow_expired_tenders boolean not null default false,
    llm_prefilter_limit integer not null default 30
);

insert into subscription_matching_config
    (subscription, min_vector_score, max_candidates, allow_expired_tenders, llm_prefilter_limit)
values
    ('trial', 0.7200, 10, false, 20),
    ('standard', 0.6800, 25, false, 50),
    ('premium', 0.6200, 50, true, 100)
on conflict (subscription) do nothing;

create table matching_runs (
    id uuid primary key default gen_random_uuid(),
    client_id uuid not null references clients(id) on delete cascade,
    trigger_type text not null,
    candidates_seen integer not null default 0,
    candidates_rejected integer not null default 0,
    matches_upserted integer not null default 0,
    status text not null default 'running',
    started_at timestamptz not null default now(),
    finished_at timestamptz
);

create table client_matches (
    id uuid primary key default gen_random_uuid(),
    client_id uuid not null references clients(id) on delete cascade,
    tender_id uuid not null references tenders(id) on delete cascade,
    matching_run_id uuid references matching_runs(id),
    vector_score numeric(6,5),
    llm_score numeric(6,5),
    final_score numeric(6,5) not null,
    fit_category match_fit_category not null,
    recommendation text not null,
    why_match jsonb not null default '[]'::jsonb,
    why_not jsonb not null default '[]'::jsonb,
    risk_notes jsonb not null default '[]'::jsonb,
    badges text[] not null default '{}',
    approved_for_delivery boolean not null default false,
    delivered_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    unique (client_id, tender_id)
);

create table domain_events (
    id uuid primary key default gen_random_uuid(),
    event_type text not null,
    aggregate_type text not null,
    aggregate_id uuid not null,
    client_id uuid references clients(id),
    payload jsonb not null default '{}'::jsonb,
    occurred_at timestamptz not null default now(),
    processed_at timestamptz
);

create table automation_configs (
    id uuid primary key default gen_random_uuid(),
    name text not null unique,
    trigger_type text not null,
    target_url_placeholder text not null default 'WEBHOOK_URL',
    max_attempts integer not null default 3,
    is_enabled boolean not null default true,
    created_at timestamptz not null default now()
);

create table automation_outbox (
    id uuid primary key default gen_random_uuid(),
    automation_config_id uuid not null references automation_configs(id),
    domain_event_id uuid references domain_events(id),
    payload jsonb not null,
    status automation_run_status not null default 'queued',
    attempts integer not null default 0,
    locked_until timestamptz,
    next_attempt_at timestamptz not null default now(),
    created_at timestamptz not null default now()
);

create table automation_runs (
    id uuid primary key default gen_random_uuid(),
    automation_outbox_id uuid not null references automation_outbox(id),
    status automation_run_status not null,
    response_status integer,
    response_body text,
    error_message text,
    started_at timestamptz not null default now(),
    finished_at timestamptz
);

create table whatsapp_sessions (
    id uuid primary key default gen_random_uuid(),
    client_id uuid references clients(id),
    wa_id text not null,
    state text not null default 'active',
    last_message_at timestamptz,
    created_at timestamptz not null default now(),
    unique (wa_id)
);

create table whatsapp_messages (
    id uuid primary key default gen_random_uuid(),
    session_id uuid not null references whatsapp_sessions(id) on delete cascade,
    direction text not null check (direction in ('inbound', 'outbound')),
    message_type text not null,
    body text,
    provider_message_id text,
    status text,
    created_at timestamptz not null default now()
);

create table crm_identity_map (
    id uuid primary key default gen_random_uuid(),
    client_id uuid not null references clients(id) on delete cascade,
    crm_system text not null,
    crm_account_id text,
    crm_opportunity_id text,
    last_synced_at timestamptz,
    unique (crm_system, crm_account_id)
);

create index idx_tenders_status_deadline on tenders(status, deadline_at);
create index idx_client_matches_client_score on client_matches(client_id, final_score desc);
create index idx_domain_events_unprocessed on domain_events(occurred_at) where processed_at is null;
create index idx_automation_outbox_due on automation_outbox(next_attempt_at, status);

-- Optional in production: ivfflat/hnsw index after enough rows exist.
-- create index idx_tender_embeddings_vector on tender_embeddings using ivfflat (embedding vector_cosine_ops);

