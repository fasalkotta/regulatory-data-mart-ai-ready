with customers as (
    select *
    from {{ ref('stg_customers') }}
),

assignments as (
    select *
    from {{ ref('stg_customer_entity_assignments') }}
)

select
    md5(
        concat_ws(
            '|',
            customers.customer_id,
            coalesce(assignments.legal_entity_id, 'UNASSIGNED'),
            coalesce(assignments.valid_from::varchar, customers.onboarding_date::varchar)
        )
    ) as customer_scd_key,
    customers.customer_id,
    assignments.legal_entity_id,
    customers.customer_type,
    customers.customer_country_code,
    customers.risk_rating,
    customers.kyc_status,
    customers.onboarding_date,
    assignments.assignment_reason,
    coalesce(assignments.valid_from, customers.onboarding_date) as valid_from,
    assignments.valid_to,
    iff(assignments.valid_to is null, true, false) as is_current,
    customers.source_system as customer_source_system,
    assignments.source_system as assignment_source_system,
    greatest(customers.loaded_at, assignments.loaded_at) as loaded_at
from customers
left join assignments
    on customers.customer_id = assignments.customer_id

