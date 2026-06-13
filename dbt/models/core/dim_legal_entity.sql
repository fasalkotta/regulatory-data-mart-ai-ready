select
    legal_entity_id,
    legal_entity_name,
    entity_country_code,
    entity_type,
    is_active,
    source_system,
    loaded_at
from {{ ref('stg_legal_entities') }}
