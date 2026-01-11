
  
    
    

    create  table
      "interview"."main"."gold_user_activity_events__dbt_tmp"
  
    as (
      -- gold_user_activity_events
-- Purpose: unified user activity across the platform, suitable for BI KPI reporting
-- Grain: one row per user activity event

-- Notes:
-- - We retain employee and unlicensed activity for auditing/debugging and flexibility.
-- - Usage KPIs should generally filter to is_billable_user_activity = true.



with navigation as (
    select
        event_id,
        user_id,
        org_id,
        event_timestamp,
        'navigation' as event_type,
        null as transformation_type,
        null as input_word_count
    from "interview"."main"."silver_navigation"
),

toolbar_transformations as (
    select
        event_id,
        user_id,
        org_id,
        event_timestamp,
        'transformation' as event_type,
        'toolbar' as transformation_type,          
        input_word_count
    from "interview"."main"."silver_toolbar_transformations"
),

research_transformations as (
    select
        event_id,
        user_id,
        org_id,
        event_timestamp,
        'transformation' as event_type,
        'research' as transformation_type,
        input_word_count
    from "interview"."main"."silver_transformations"
),

all_events as (
    select * from navigation
    union all
    select * from toolbar_transformations
    union all
    select * from research_transformations
),

enriched as (
    select
        e.event_id,
        e.user_id,
        e.org_id,
        e.event_timestamp,
        e.event_type,
        e.transformation_type,
        e.input_word_count,
        u.is_autogenai_employee,
        u.is_licensed_user,
        case
            when coalesce(u.is_autogenai_employee, false) = false
             and coalesce(u.is_licensed_user, false) = true
            then true
            else false
        end as is_billable_user_activity
    from all_events e
    left join "interview"."main"."silver_users" u
        on e.user_id = u.user_id
)

select *
from enriched
    );
  
  