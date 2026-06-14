# Demo Script

Use this script to present the project in an interview or walkthrough.

## 30 Second Summary

I built an AI-ready regulatory data mart that converts raw operational data into trusted monthly reporting outputs by legal entity and jurisdiction. Snowflake stores the warehouse layers, dbt owns transformations and tests, Airflow orchestrates the build, Streamlit provides a self-serve dashboard, and GitHub Actions runs CI checks. The project also includes machine-readable metric definitions, data contracts, and AI prompt rules so regulatory logic is documented and auditable.

## 2 Minute Walkthrough

1. Start with the problem.

   Regulatory reporting often depends on manual pulls, spreadsheet logic, and repeated interpretation of metric definitions. That creates risk for compliance teams because the same question can be answered differently by different people.

2. Show the architecture.

   The project moves data through raw, staging, core, OBT, and mart layers. Each layer has a clear purpose. The final marts are designed for compliance, legal, business operations, and analytics users.

3. Explain the dbt model.

   The core layer creates facts and dimensions. `fact_transaction` is the transaction-grain fact table. `dim_customer_scd`, `dim_legal_entity`, and `dim_jurisdiction` provide customer, entity, and jurisdiction context.

4. Explain the marts.

   The main mart is `mart_entity_monthly_regulatory_report`, which creates reporting rows by month, legal entity, and jurisdiction. It calculates reportable volume, KYC flags, high-risk activity, and report status.

5. Explain data quality.

   dbt tests validate keys, accepted values, and relationships. The DQ mart exposes missing customer, missing legal entity, rejected KYC, high-risk jurisdiction, duplicate ID, and negative amount issues.

6. Explain reconciliation.

   `mart_reconciliation_status` compares counts and volume across raw, staging, fact, OBT, and mart layers. This gives users confidence that the mart aligns with upstream data.

7. Show the dashboard.

   The Streamlit app shows key reporting metrics, report status distribution, data quality exceptions, reconciliation status, and approved metric definitions.

8. Explain AI readiness.

   The `metrics/` folder stores approved metric definitions, data contracts, caveats, and prompt rules. AI can use these artifacts to draft SQL or explanations, but outputs still require validation against dbt tests, reconciliation, and human review rules.

9. Explain CI.

   GitHub Actions runs dbt parse, dbt compile, and dashboard Python syntax checks on push and pull request. In a company environment, the main branch would be protected so code could only merge after CI passes.

## Questions To Be Ready For

### Why use dbt?

dbt keeps SQL transformations version-controlled, testable, modular, and repeatable. It also helps separate raw source cleanup from reusable facts, dimensions, and business-facing marts.

### Why use Airflow if dbt already runs models?

dbt transforms and tests data. Airflow schedules and orchestrates workflows. In production, Airflow can run dbt, source checks, alerts, and downstream refresh steps in a controlled order.

### Why have an OBT?

The OBT gives analysts and dashboards a wide transaction-level model with common joins already applied. This reduces repeated join logic while keeping final mart aggregations clear and governed.

### What makes this AI-ready?

The metric logic is not hidden only in code or human memory. It is captured in structured YAML and Markdown with grains, filters, caveats, and review rules. AI can reference those artifacts, but the project still requires human oversight.

### What would you improve next?

I would add production alerting, source freshness checks, dbt exposures, a published dbt docs site, and a manually approved deployment workflow using protected environments and Snowflake secrets.

## Demo Order

Use this order when presenting:

1. README architecture diagram
2. dbt model folders
3. main mart SQL
4. dbt tests in schema YAML
5. Streamlit dashboard screenshot or running app
6. governance files under `metrics/`
7. Airflow DAG
8. GitHub Actions CI workflow

