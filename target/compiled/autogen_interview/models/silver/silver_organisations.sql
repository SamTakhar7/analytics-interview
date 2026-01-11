with src as (
    select *
    from "interview"."main"."raw_organisations"
),

typed as (
    select
        cast(id as varchar) as org_id,
        cast(name as varchar) as org_name,
        cast(is_active_customer as boolean) as is_active_customer,
        cast(contracted_licences as integer) as contracted_licences,
        cast(created_at as timestamp) as created_at
    from src
),

deduped as (
    select *
    from (
        select
            *,
            row_number() over (
                partition by org_id
                order by created_at desc nulls last
            ) as rn
        from typed
    ) t
    where rn = 1
)

select
    org_id,
    org_name,
    is_active_customer,
    contracted_licences,
    created_at
from deduped