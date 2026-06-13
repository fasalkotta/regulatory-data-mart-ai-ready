select
    jurisdiction_code,
    jurisdiction_name,
    region,
    is_high_risk,
    source_system,
    loaded_at
from {{ ref('stg_jurisdictions') }}
