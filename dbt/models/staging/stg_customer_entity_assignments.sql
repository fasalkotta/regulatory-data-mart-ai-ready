with source as (
    select *
    from {{ source('raw', 'RAW_CUSTOMER_ENTITY_ASSIGNMENTS') }}
    where customer_id is not null
),

deduped as (
    select
        customer_id,
        legal_entity_id,
        lower(assignment_reason) as assignment_reason,
        valid_from,
        valid_to,
        source_system,
        loaded_at,
        row_number() over (
            partition by customer_id, legal_entity_id, valid_from
            order by loaded_at desc
        ) as row_num
    from source
)

select
    customer_id,
    legal_entity_id,
    assignment_reason,
    valid_from,
    valid_to,
    source_system,
    loaded_at
from deduped
where row_num = 1

