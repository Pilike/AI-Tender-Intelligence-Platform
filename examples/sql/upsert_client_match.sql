-- Simplified and sanitized match upsert.
-- Purpose: persist an explainable LLM-evaluated match without creating duplicates.

create or replace function upsert_client_match(
    p_client_id uuid,
    p_tender_id uuid,
    p_matching_run_id uuid,
    p_vector_score numeric,
    p_llm_score numeric,
    p_final_score numeric,
    p_fit_category match_fit_category,
    p_recommendation text,
    p_why_match jsonb default '[]'::jsonb,
    p_why_not jsonb default '[]'::jsonb,
    p_risk_notes jsonb default '[]'::jsonb,
    p_badges text[] default '{}',
    p_approved_for_delivery boolean default false
)
returns uuid
language plpgsql
as $$
declare
    v_match_id uuid;
begin
    insert into client_matches (
        client_id,
        tender_id,
        matching_run_id,
        vector_score,
        llm_score,
        final_score,
        fit_category,
        recommendation,
        why_match,
        why_not,
        risk_notes,
        badges,
        approved_for_delivery
    )
    values (
        p_client_id,
        p_tender_id,
        p_matching_run_id,
        p_vector_score,
        p_llm_score,
        p_final_score,
        p_fit_category,
        p_recommendation,
        coalesce(p_why_match, '[]'::jsonb),
        coalesce(p_why_not, '[]'::jsonb),
        coalesce(p_risk_notes, '[]'::jsonb),
        coalesce(p_badges, '{}'),
        p_approved_for_delivery
    )
    on conflict (client_id, tender_id)
    do update set
        matching_run_id = excluded.matching_run_id,
        vector_score = excluded.vector_score,
        llm_score = excluded.llm_score,
        final_score = excluded.final_score,
        fit_category = excluded.fit_category,
        recommendation = excluded.recommendation,
        why_match = excluded.why_match,
        why_not = excluded.why_not,
        risk_notes = excluded.risk_notes,
        badges = excluded.badges,
        approved_for_delivery = excluded.approved_for_delivery,
        updated_at = now()
    returning id into v_match_id;

    return v_match_id;
end;
$$;

