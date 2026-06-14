with regulatory_transactions as (

    select *
    from {{ ref('obt_regulatory_transaction') }}

),

aggregated as (

    select
        reporting_month,
        legal_entity_id,
        legal_entity_name,
        entity_country_code,
        jurisdiction_code,
        jurisdiction_name,
        region,

        count(*) as total_transaction_count,

        sum(
            case
                when transaction_status = 'SETTLED' then 1
                else 0
            end
        ) as settled_transaction_count,

        sum(settled_volume_usd) as reportable_settled_volume_usd,

        sum(settled_fee_usd) as settled_fee_usd,

        count(distinct customer_id) as active_customer_count,

        count(
            distinct case
                when risk_rating = 'HIGH' then customer_id
            end
        ) as high_risk_customer_count,

        sum(
            case
                when risk_rating = 'HIGH' then settled_volume_usd
                else 0
            end
        ) as high_risk_settled_volume_usd,

        sum(
            case
                when kyc_status = 'PENDING' then 1
                else 0
            end
        ) as pending_kyc_transaction_count,

        sum(
            case
                when kyc_status = 'REJECTED' then 1
                else 0
            end
        ) as rejected_kyc_transaction_count,

        sum(
            case
                when is_high_risk_jurisdiction then 1
                else 0
            end
        ) as high_risk_jurisdiction_transaction_count,

        sum(
            case
                when transaction_status = 'SETTLED'
                and customer_country_code <> entity_country_code
                and settled_volume_usd >= 10000
                then settled_volume_usd
                else 0
            end
        ) as high_value_cross_border_settled_volume_usd,

        sum(
            case
                when transaction_status = 'SETTLED'
                and customer_country_code <> entity_country_code
                and settled_volume_usd >= 1
                then 1
                else 0
            end
        ) as high_value_cross_border_transaction_count
        

    from regulatory_transactions
    group by
        reporting_month,
        legal_entity_id,
        legal_entity_name,
        entity_country_code,
        jurisdiction_code,
        jurisdiction_name,
        region

)

select
    *,
    case
        when rejected_kyc_transaction_count > 0 then 'BLOCKED'
        when pending_kyc_transaction_count > 0 then 'REVIEW'
        when high_risk_jurisdiction_transaction_count > 0 then 'REVIEW'
        when high_value_cross_border_transaction_count > 0 then 'REVIEW'
        else 'PASS'
    end as report_status
from aggregated