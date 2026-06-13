with source as (
    select *
    from {{ source('raw', 'RAW_TRANSACTIONS') }}
    where transaction_id is not null
),

standardized as (
    select
        transaction_id,
        customer_id,
        transaction_timestamp,
        date_trunc('month', transaction_timestamp)::date as reporting_month,
        upper(asset_symbol) as asset_symbol,
        upper(transaction_type) as transaction_type,
        upper(transaction_status) as transaction_status,
        gross_usd_amount,
        fee_usd_amount,
        upper(jurisdiction_code) as jurisdiction_code,
        source_system,
        loaded_at
    from source
)

select
    transaction_id,
    customer_id,
    transaction_timestamp,
    reporting_month,
    asset_symbol,
    transaction_type,
    transaction_status,
    gross_usd_amount,
    fee_usd_amount,
    jurisdiction_code,
    source_system,
    loaded_at
from standardized

