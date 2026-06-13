{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set base_schema = target.schema | trim -%}
    {%- set requested_schema = custom_schema_name | trim if custom_schema_name is not none else base_schema -%}

    {%- if target.name == 'dev' -%}
        {{ base_schema }}_{{ requested_schema }}
    {%- else -%}
        {{ requested_schema }}
    {%- endif -%}
{%- endmacro %}

