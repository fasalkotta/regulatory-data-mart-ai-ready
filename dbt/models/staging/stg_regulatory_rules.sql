with source as (
    select *
    from {{ source('raw', 'RAW_REGULATORY_RULES') }}
    where rule_id is not null
),

deduped as (
    select
        rule_id,
        legal_entity_id,
        upper(jurisdiction_code) as jurisdiction_code,
        upper(metric_name) as metric_name,
        rule_description,
        is_reportable,
        effective_from,
        effective_to,
        source_system,
        loaded_at,
        row_number() over (
            partition by rule_id
            order by loaded_at desc
        ) as row_num
    from source
)

select
    rule_id,
    legal_entity_id,
    jurisdiction_code,
    metric_name,
    rule_description,
    is_reportable,
    effective_from,
    effective_to,
    source_system,
    loaded_at
from deduped
where row_num = 1

