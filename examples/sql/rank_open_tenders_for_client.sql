-- Simplified and sanitized ranking RPC.
-- Purpose: pick candidate tenders before sending a smaller, higher-quality set to an LLM evaluator.

create or replace function rank_open_tenders_for_client(
    p_client_id uuid,
    p_now timestamptz default now()
)
returns table (
    tender_id uuid,
    title text,
    buyer_name text,
    deadline_at timestamptz,
    vector_score numeric,
    rule_score numeric,
    final_candidate_score numeric
)
language sql
stable
as $$
    with client_context as (
        select
            c.id as client_id,
            c.subscription,
            cp.embedding as client_embedding,
            cp.service_roles,
            cp.activity_domains,
            cp.exclusion_terms,
            cfg.min_vector_score,
            cfg.max_candidates,
            cfg.allow_expired_tenders
        from clients c
        join client_profiles cp on cp.client_id = c.id
        join subscription_matching_config cfg on cfg.subscription = c.subscription
        where c.id = p_client_id
          and c.is_active = true
        order by cp.profile_version desc
        limit 1
    ),
    candidates as (
        select
            t.id as tender_id,
            t.title,
            t.buyer_name,
            t.deadline_at,
            (1 - (te.embedding <=> cc.client_embedding))::numeric(6,5) as vector_score,
            case
                when exists (
                    select 1
                    from unnest(cc.service_roles) role
                    where t.normalized_payload::text ilike '%' || role || '%'
                ) then 0.08
                else 0
            end
            +
            case
                when exists (
                    select 1
                    from unnest(cc.activity_domains) domain
                    where t.normalized_payload::text ilike '%' || domain || '%'
                ) then 0.05
                else 0
            end
            -
            case
                when exists (
                    select 1
                    from unnest(cc.exclusion_terms) term
                    where t.normalized_payload::text ilike '%' || term || '%'
                ) then 0.20
                else 0
            end as rule_score,
            cc.min_vector_score,
            cc.max_candidates,
            cc.allow_expired_tenders
        from client_context cc
        join tender_embeddings te on cc.client_embedding is not null
        join tenders t on t.id = te.tender_id
        where t.status = 'open'
          and (cc.allow_expired_tenders or t.deadline_at is null or t.deadline_at > p_now)
    )
    select
        tender_id,
        title,
        buyer_name,
        deadline_at,
        vector_score,
        rule_score,
        (vector_score + rule_score)::numeric(6,5) as final_candidate_score
    from candidates
    where vector_score >= min_vector_score
    order by final_candidate_score desc, deadline_at nulls last
    limit (select max_candidates from client_context);
$$;

