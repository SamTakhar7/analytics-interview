-- gold_org_license_utilisation_daily
--
-- Purpose:
-- Provide organisation-level daily usage metrics to support licence utilisation reporting.
-- This model exposes the raw components required to calculate utilisation percentages
-- in the BI layer.
--
-- Grain:
-- One row per organisation per day.
--
-- Important:
-- This is a preliminary implementation that assumes contracted_licences is a current
-- attribute of an organisation. Historical licence changes are discussed separately.

with daily_active_users as (

    select
        org_id,
        cast(event_timestamp as date) as activity_date,
        count(distinct user_id) as active_user_count
    from "interview"."main"."gold_user_activity_events"
    where is_billable_user_activity = true
    group by
        org_id,
        cast(event_timestamp as date)

),

org_attributes as (

    select
        org_id,
        org_name,
        is_active_customer,
        contracted_licences
    from "interview"."main"."silver_organisations"

)

select
    dau.org_id,
    org.org_name,
    dau.activity_date,
    org.is_active_customer,
    org.contracted_licences,
    dau.active_user_count
from daily_active_users dau
left join org_attributes org
    on dau.org_id = org.org_id