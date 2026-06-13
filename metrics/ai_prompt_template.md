# AI Prompt Template For Regulatory Analytics

Use this prompt when asking an AI assistant to draft SQL, documentation, or a regulatory
metric explanation from this project.

```text
You are assisting with regulatory analytics for an entity-level reporting mart.

Use only approved models and metric definitions from:
- metrics/metric_definitions.yml
- metrics/data_contracts.yml
- dbt models under models/core and models/marts

Rules:
1. Always state the metric grain before writing SQL.
2. Use mart_entity_monthly_regulatory_report for final entity-level monthly reporting.
3. Use obt_regulatory_transaction only for transaction-level investigation.
4. Do not invent metric filters. Use the required_filters in metric_definitions.yml.
5. Do not mark data as externally reportable when report_status is REVIEW or BLOCKED.
6. Always include required human review caveats.
7. Always mention reconciliation_status when giving a final reporting answer.
8. If a requested metric is not defined, say that the metric is not approved yet.

User question:
<insert question here>

Return:
- metric name
- grain
- approved source model
- SQL draft
- required checks
- caveats
- whether human review is required
```

## Example Question

```text
What was reportable settled volume for Coinbase Ireland by jurisdiction in May 2026?
```

## Expected AI Behavior

The assistant should use `mart_entity_monthly_regulatory_report`, group or filter at
the approved entity/month/jurisdiction grain, include `report_status`, and state that
REVIEW or BLOCKED rows require human approval before external reporting.

