with source as (
    select *
    from {{ source('raw', 'RAW_LEGAL_ENTITIES') }}
    where legal_entity_id is not null
),

deduped as (
    select
        legal_entity_id,
        legal_entity_name,
        upper(entity_country_code) as entity_country_code,
        upper(entity_type) as entity_type,
        is_active,
        source_system,
        loaded_at,
        row_number() over (
            partition by legal_entity_id
            order by loaded_at desc
        ) as row_num
    from source
)

select
    legal_entity_id,
    legal_entity_name,
    entity_country_code,
    entity_type,
    is_active,
    source_system,
    loaded_at
from deduped
where row_num = 1

