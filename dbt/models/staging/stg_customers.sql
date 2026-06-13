with source as (
    select *
    from {{ source('raw', 'RAW_CUSTOMERS') }}
    where customer_id is not null
),

deduped as (
    select
        customer_id,
        upper(customer_type) as customer_type,
        upper(customer_country_code) as customer_country_code,
        upper(risk_rating) as risk_rating,
        upper(kyc_status) as kyc_status,
        onboarding_date,
        source_system,
        loaded_at,
        row_number() over (
            partition by customer_id
            order by loaded_at desc
        ) as row_num
    from source
)

select
    customer_id,
    customer_type,
    customer_country_code,
    risk_rating,
    kyc_status,
    onboarding_date,
    source_system,
    loaded_at
from deduped
where row_num = 1

