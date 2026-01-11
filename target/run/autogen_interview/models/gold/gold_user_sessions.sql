
  
    
    

    create  table
      "interview"."main"."gold_user_sessions__dbt_tmp"
  
    as (
      -- gold_user_sessions
--
-- Purpose:
-- Derive user-level sessions from platform activity using a 30-minute inactivity threshold.
-- This model centralises sessionisation logic so that BI tools can reliably compute
-- engagement metrics such as sessions per user and session length without reimplementing
-- complex windowing logic.
--
-- Grain:
-- One row per user per session.
--
-- Design notes:
-- - Sessions are derived across all user activity types (navigation and transformations).
-- - A new session is started when there is a gap of more than 30 minutes between consecutive
--   activity events for the same user.
-- - Session length is calculated as the difference between the first and last observed
--   activity timestamps within a session.
--
-- Key assumptions:
-- - Gaps of 30 minutes or less are treated as continuous engagement within the same session.
-- - Sessions are scoped at the user level (not device-level).
-- - Internal AutogenAI employees and unlicensed users are excluded, as this model is intended
--   to support customer usage
--
-- Rationale:
-- Implementing sessionisation in the analytics layer ensures consistent, deterministic
-- session definitions and keeps downstream reporting logic simple, performant, and
-- easy to reason about.

with ordered_events as (

    select
        user_id,
        org_id,
        event_timestamp,
        event_type,
        transformation_type,

        lag(event_timestamp) over (
            partition by user_id
            order by event_timestamp
        ) as prev_event_timestamp

    from "interview"."main"."gold_user_activity_events"
    where is_billable_user_activity = true

),

session_flags as (

    select
        *,
        case
            when prev_event_timestamp is null then 1
            when datediff(
                'minute',
                prev_event_timestamp,
                event_timestamp
            ) > 30 then 1
            else 0
        end as is_new_session
    from ordered_events

),

session_ids as (

    select
        *,
        sum(is_new_session) over (
            partition by user_id
            order by event_timestamp
            rows unbounded preceding
        ) as session_number
    from session_flags

),

aggregated_sessions as (

    select
        user_id,
        org_id,
        session_number,

        min(event_timestamp) as session_start_timestamp,
        max(event_timestamp) as session_end_timestamp,

        datediff(
            'minute',
            min(event_timestamp),
            max(event_timestamp)
        ) as session_length_minutes,

        count(*) as event_count,

        -- Session composition / what happened during the session
        sum(
            case
                when event_type = 'navigation'
                then 1 else 0
            end
        ) as navigation_event_count,

        sum(
            case
                when event_type = 'transformation'
                 and transformation_type is not null
                 and transformation_type <> 'research'
                then 1 else 0
            end
        ) as toolbar_transformation_count,

        sum(
            case
                when event_type = 'transformation'
                 and transformation_type = 'research'
                then 1 else 0
            end
        ) as research_transformation_count

    from session_ids
    group by
        user_id,
        org_id,
        session_number
)

select
    user_id,
    org_id,
    session_number,
    session_start_timestamp,
    session_end_timestamp,
    session_length_minutes,
    event_count,
    navigation_event_count,
    toolbar_transformation_count,
    research_transformation_count
from aggregated_sessions
    );
  
  