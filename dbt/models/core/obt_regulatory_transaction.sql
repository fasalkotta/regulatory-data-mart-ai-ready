with transactions as (

    select *
    from {{ ref('fact_transaction') }}

),

customers as (

    select *
    from {{ ref('dim_customer_scd') }}

),

legal_entities as (

    select *
    from {{ ref('dim_legal_entity') }}

),

jurisdictions as (

    select *
    from {{ ref('dim_jurisdiction') }}

)

select
    transactions.transaction_id,
    transactions.customer_id,
    transactions.customer_scd_key,
    transactions.legal_entity_id,
    legal_entities.legal_entity_name,
    legal_entities.entity_country_code,
    transactions.jurisdiction_code,
    jurisdictions.jurisdiction_name,
    jurisdictions.region,
    jurisdictions.is_high_risk as is_high_risk_jurisdiction,
    customers.customer_type,
    customers.customer_country_code,
    customers.risk_rating,
    customers.kyc_status,
    transactions.reporting_month,
    transactions.transaction_timestamp,
    transactions.asset_symbol,
    transactions.transaction_type,
    transactions.transaction_status,
    transactions.gross_usd_amount,
    transactions.fee_usd_amount,
    transactions.settled_volume_usd,
    transactions.settled_fee_usd,
    transactions.source_system,
    transactions.loaded_at
from transactions
left join customers
    on transactions.customer_scd_key = customers.customer_scd_key
left join legal_entities
    on transactions.legal_entity_id = legal_entities.legal_entity_id
left join jurisdictions
    on transactions.jurisdiction_code = jurisdictions.jurisdiction_code