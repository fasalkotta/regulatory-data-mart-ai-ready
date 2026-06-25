with transactions as (

    select *
    from {{ ref('obt_regulatory_transaction') }}

),

duplicate_transactions as (

    select
        transaction_id
    from transactions
    group by transaction_id
    having count(*) > 1

),

dq_events as (

    select
        reporting_month,
        legal_entity_id,
        legal_entity_name,
        jurisdiction_code,
        jurisdiction_name,
        transaction_id,
        'MISSING_CUSTOMER' as dq_rule_code,
        'BLOCKED' as severity
    from transactions
    where customer_id is null
       or customer_type is null

    union all

    select
        reporting_month,
        legal_entity_id,
        legal_entity_name,
        jurisdiction_code,
        jurisdiction_name,
        transaction_id,
        'MISSING_LEGAL_ENTITY' as dq_rule_code,
        'BLOCKED' as severity
    from transactions
    where legal_entity_id is null

    union all

    select
        reporting_month,
        legal_entity_id,
        legal_entity_name,
        jurisdiction_code,
        jurisdiction_name,
        transaction_id,
        'MISSING_JURISDICTION' as dq_rule_code,
        'BLOCKED' as severity
    from transactions
    where jurisdiction_code is null
       or jurisdiction_name is null

    union all

    select
        t.reporting_month,
        t.legal_entity_id,
        t.legal_entity_name,
        t.jurisdiction_code,
        t.jurisdiction_name,
        t.transaction_id,
        'DUPLICATE_TRANSACTION_ID' as dq_rule_code,
        'BLOCKED' as severity
    from transactions t
    inner join duplicate_transactions d
        on t.transaction_id = d.transaction_id

    union all

    select
        reporting_month,
        legal_entity_id,
        legal_entity_name,
        jurisdiction_code,
        jurisdiction_name,
        transaction_id,
        'NEGATIVE_AMOUNT' as dq_rule_code,
        'BLOCKED' as severity
    from transactions
    where gross_usd_amount < 0
       or fee_usd_amount < 0

    union all

    select
        reporting_month,
        legal_entity_id,
        legal_entity_name,
        jurisdiction_code,
        jurisdiction_name,
        transaction_id,
        'PENDING_KYC' as dq_rule_code,
        'REVIEW' as severity
    from transactions
    where kyc_status = 'PENDING'

    union all

    select
        reporting_month,
        legal_entity_id,
        legal_entity_name,
        jurisdiction_code,
        jurisdiction_name,
        transaction_id,
        'HIGH_VALUE_CROSS_BORDER' as dq_rule_code,
        'REVIEW' as severity
    from transactions
    where transaction_status = 'SETTLED'
      and customer_country_code <> entity_country_code
      and settled_volume_usd >= 10000

    union all
    
    select
        reporting_month,
        legal_entity_id,
        legal_entity_name,
        jurisdiction_code,
        jurisdiction_name,
        transaction_id,
        'REJECTED_KYC' as dq_rule_code,
        'BLOCKED' as severity
    from transactions
    where kyc_status = 'REJECTED'

    union all

    select
        reporting_month,
        legal_entity_id,
        legal_entity_name,
        jurisdiction_code,
        jurisdiction_name,
        transaction_id,
        'HIGH_RISK_JURISDICTION' as dq_rule_code,
        'REVIEW' as severity
    from transactions
    where is_high_risk_jurisdiction = true

)

select
    reporting_month,
    legal_entity_id,
    legal_entity_name,
    jurisdiction_code,
    jurisdiction_name,
    dq_rule_code,
    severity,
    count(*) as exception_count,
    count(distinct transaction_id) as impacted_transaction_count,
    case when datediff(day,reporting_month,current_date) >= 30 and Severity <> 'REVIEW' then 'Flagged' else 'Not Flagged' end as 30days_flagged

from dq_events
group by
    reporting_month,
    legal_entity_id,
    legal_entity_name,
    jurisdiction_code,
    jurisdiction_name,
    dq_rule_code,
    severity