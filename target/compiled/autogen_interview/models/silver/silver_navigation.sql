with src as (
    select *
    from "interview"."main"."raw_navigation"
),

typed as (
    select
        cast(event_id as varchar) as event_id,
        cast(user_id as varchar) as user_id,
        cast(org_id as varchar) as org_id,
        cast(event_timestamp as timestamp) as event_timestamp
    from src
),

deduped as (
    select *
    from (
        select
            *,
            row_number() over (
                partition by event_id
                order by event_timestamp desc nulls last
            ) as rn
        from typed
    ) t
    where rn = 1
)

select
    event_id,
    user_id,
    org_id,
    event_timestamp
from deduped