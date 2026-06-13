# AI-Ready Governance Layer

This project treats AI as an assistant, not a source of truth.

The governance layer defines approved regulatory metrics, data contracts, and prompt
rules in machine-readable files so an AI assistant can draft SQL or documentation
without inventing business logic.

## Files

- `metrics/metric_definitions.yml`: approved metric definitions, grain, filters, caveats, and human review rules.
- `metrics/data_contracts.yml`: required fields, accepted values, owners, consumers, and quality expectations.
- `metrics/ai_prompt_template.md`: prompt rules for AI-assisted SQL and regulatory question answering.

## Design Principle

The mart remains the source of truth. AI-generated outputs must be checked against:

- approved metric definitions
- dbt model grain
- data quality exception summaries
- reconciliation status
- human review requirements

## Interview Summary

I made the regulatory mart AI-ready by turning metric definitions, data contracts, and
review rules into durable machine-readable artifacts. AI can use these definitions to
draft SQL or explanations, but humans still verify outputs against dbt tests, DQ
exceptions, and reconciliation status before anything is used for regulatory reporting.

