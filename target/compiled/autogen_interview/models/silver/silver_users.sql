with src as (
    select *
    from "interview"."main"."raw_users"
),

typed as (
    select
        cast(id as varchar) as user_id,
        cast(org_id as varchar) as org_id,
        cast(email as varchar) as email,
        cast(job_title as varchar) as job_title,
        cast(is_autogenai_employee as boolean) as is_autogenai_employee,
        cast(is_licensed_user as boolean) as is_licensed_user,
        cast(created_at as timestamp) as created_at
    from src
),

deduped as (
    select *
    from (
        select
            *,
            row_number() over (
                partition by user_id
                order by created_at desc nulls last
            ) as rn
        from typed
    ) t
    where rn = 1
)

select
    user_id,
    org_id,
    email,
    job_title,
    is_autogenai_employee,
    is_licensed_user,
    created_at
from deduped