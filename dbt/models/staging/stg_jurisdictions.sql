with source as (
    select *
    from {{ source('raw', 'RAW_JURISDICTIONS') }}
    where jurisdiction_code is not null
),

deduped as (
    select
        upper(jurisdiction_code) as jurisdiction_code,
        jurisdiction_name,
        region,
        is_high_risk,
        source_system,
        loaded_at,
        row_number() over (
            partition by upper(jurisdiction_code)
            order by loaded_at desc
        ) as row_num
    from source
)

select
    jurisdiction_code,
    jurisdiction_name,
    region,
    is_high_risk,
    source_system,
    loaded_at
from deduped
where row_num = 1

