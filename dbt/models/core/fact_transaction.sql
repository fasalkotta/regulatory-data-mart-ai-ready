with transactions as (
    select *
    from {{ ref('stg_transactions') }}
),

customer_history as (
    select *
    from {{ ref('dim_customer_scd') }}
),

joined as (
    select
        transactions.transaction_id,
        transactions.customer_id,
        customer_history.customer_scd_key,
        customer_history.legal_entity_id,
        transactions.jurisdiction_code,
        transactions.reporting_month,
        transactions.transaction_timestamp,
        transactions.asset_symbol,
        transactions.transaction_type,
        transactions.transaction_status,
        transactions.gross_usd_amount,
        transactions.fee_usd_amount,
        iff(transactions.transaction_status = 'SETTLED', transactions.gross_usd_amount, 0) as settled_volume_usd,
        iff(transactions.transaction_status = 'SETTLED', transactions.fee_usd_amount, 0) as settled_fee_usd,
        transactions.source_system,
        transactions.loaded_at
    from transactions
    left join customer_history
        on transactions.customer_id = customer_history.customer_id
        and transactions.transaction_timestamp::date >= customer_history.valid_from
        and (
            customer_history.valid_to is null
            or transactions.transaction_timestamp::date < customer_history.valid_to
        )
)

select *
from joined

