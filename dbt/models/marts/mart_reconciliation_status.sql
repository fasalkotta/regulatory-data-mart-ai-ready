with raw_transactions as (

    select
        date_trunc('month', transaction_timestamp)::date as reporting_month,
        count(*) as raw_transaction_count,
        sum(
            case
                when upper(transaction_status) = 'SETTLED' then gross_usd_amount
                else 0
            end
        ) as raw_settled_volume_usd
    from {{ source('raw', 'RAW_TRANSACTIONS') }}
    where transaction_id is not null
    group by 1

),

stg_transactions as (

    select
        reporting_month,
        count(*) as stg_transaction_count,
        sum(
            case
                when transaction_status = 'SETTLED' then gross_usd_amount
                else 0
            end
        ) as stg_settled_volume_usd
    from {{ ref('stg_transactions') }}
    group by 1

),

fact_transactions as (

    select
        reporting_month,
        count(*) as fact_transaction_count,
        sum(settled_volume_usd) as fact_settled_volume_usd
    from {{ ref('fact_transaction') }}
    group by 1

),

obt_transactions as (

    select
        reporting_month,
        count(*) as obt_transaction_count,
        sum(settled_volume_usd) as obt_settled_volume_usd
    from {{ ref('obt_regulatory_transaction') }}
    group by 1

),

mart_report as (

    select
        reporting_month,
        sum(total_transaction_count) as mart_total_transaction_count,
        sum(reportable_settled_volume_usd) as mart_settled_volume_usd
    from {{ ref('mart_entity_monthly_regulatory_report') }}
    group by 1

),

joined as (

    select
        coalesce(
            raw_transactions.reporting_month,
            stg_transactions.reporting_month,
            fact_transactions.reporting_month,
            obt_transactions.reporting_month,
            mart_report.reporting_month
        ) as reporting_month,

        coalesce(raw_transactions.raw_transaction_count, 0) as raw_transaction_count,
        coalesce(stg_transactions.stg_transaction_count, 0) as stg_transaction_count,
        coalesce(fact_transactions.fact_transaction_count, 0) as fact_transaction_count,
        coalesce(obt_transactions.obt_transaction_count, 0) as obt_transaction_count,
        coalesce(mart_report.mart_total_transaction_count, 0) as mart_total_transaction_count,

        coalesce(raw_transactions.raw_settled_volume_usd, 0) as raw_settled_volume_usd,
        coalesce(stg_transactions.stg_settled_volume_usd, 0) as stg_settled_volume_usd,
        coalesce(fact_transactions.fact_settled_volume_usd, 0) as fact_settled_volume_usd,
        coalesce(obt_transactions.obt_settled_volume_usd, 0) as obt_settled_volume_usd,
        coalesce(mart_report.mart_settled_volume_usd, 0) as mart_settled_volume_usd
    from raw_transactions
    full outer join stg_transactions
        on raw_transactions.reporting_month = stg_transactions.reporting_month
    full outer join fact_transactions
        on coalesce(raw_transactions.reporting_month, stg_transactions.reporting_month)
            = fact_transactions.reporting_month
    full outer join obt_transactions
        on coalesce(
            raw_transactions.reporting_month,
            stg_transactions.reporting_month,
            fact_transactions.reporting_month
        ) = obt_transactions.reporting_month
    full outer join mart_report
        on coalesce(
            raw_transactions.reporting_month,
            stg_transactions.reporting_month,
            fact_transactions.reporting_month,
            obt_transactions.reporting_month
        ) = mart_report.reporting_month

)

select
    reporting_month,
    raw_transaction_count,
    stg_transaction_count,
    fact_transaction_count,
    obt_transaction_count,
    mart_total_transaction_count,
    raw_settled_volume_usd,
    stg_settled_volume_usd,
    fact_settled_volume_usd,
    obt_settled_volume_usd,
    mart_settled_volume_usd,
    stg_transaction_count - raw_transaction_count as stg_vs_raw_transaction_count_diff,
    fact_transaction_count - stg_transaction_count as fact_vs_stg_transaction_count_diff,
    obt_transaction_count - fact_transaction_count as obt_vs_fact_transaction_count_diff,
    mart_total_transaction_count - obt_transaction_count as mart_vs_obt_transaction_count_diff,
    stg_settled_volume_usd - raw_settled_volume_usd as stg_vs_raw_settled_volume_diff,
    fact_settled_volume_usd - stg_settled_volume_usd as fact_vs_stg_settled_volume_diff,
    obt_settled_volume_usd - fact_settled_volume_usd as obt_vs_fact_settled_volume_diff,
    mart_settled_volume_usd - obt_settled_volume_usd as mart_vs_obt_settled_volume_diff,
    case
        when mart_total_transaction_count <> obt_transaction_count then 'BLOCKED'
        when abs(mart_settled_volume_usd - obt_settled_volume_usd) > 0.01 then 'BLOCKED'
        when fact_transaction_count <> stg_transaction_count then 'REVIEW'
        when abs(fact_settled_volume_usd - stg_settled_volume_usd) > 0.01 then 'REVIEW'
        when stg_transaction_count <> raw_transaction_count then 'REVIEW'
        when abs(stg_settled_volume_usd - raw_settled_volume_usd) > 0.01 then 'REVIEW'
        else 'PASS'
    end as reconciliation_status
from joined

