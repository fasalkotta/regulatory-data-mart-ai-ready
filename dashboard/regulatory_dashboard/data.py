import pandas as pd
import snowflake.connector
import streamlit as st


@st.cache_resource
def get_snowflake_connection():
    cfg = st.secrets["snowflake"]

    return snowflake.connector.connect(
        account=cfg["account"],
        user=cfg["user"],
        password=cfg["password"],
        role=cfg["role"],
        warehouse=cfg["warehouse"],
        database=cfg["database"],
        schema=cfg["schema"],
    )


@st.cache_data(ttl=300)
def load_dataframe(query: str) -> pd.DataFrame:
    conn = get_snowflake_connection()
    return pd.read_sql(query, conn)


def load_regulatory_report() -> pd.DataFrame:
    return load_dataframe(
        """
        select
            reporting_month,
            legal_entity_id,
            legal_entity_name,
            entity_country_code,
            jurisdiction_code,
            jurisdiction_name,
            region,
            total_transaction_count,
            settled_transaction_count,
            reportable_settled_volume_usd,
            settled_fee_usd,
            active_customer_count,
            high_risk_customer_count,
            high_risk_settled_volume_usd,
            pending_kyc_transaction_count,
            rejected_kyc_transaction_count,
            high_risk_jurisdiction_transaction_count,
            report_status
        from mart_entity_monthly_regulatory_report
        order by reporting_month, legal_entity_name, jurisdiction_code
        """
    )


def load_dq_exception_summary() -> pd.DataFrame:
    return load_dataframe(
        """
        select
            reporting_month,
            legal_entity_id,
            legal_entity_name,
            jurisdiction_code,
            jurisdiction_name,
            dq_rule_code,
            severity,
            exception_count,
            impacted_transaction_count
        from mart_dq_exception_summary
        order by reporting_month, severity, dq_rule_code
        """
    )


def load_reconciliation_status() -> pd.DataFrame:
    return load_dataframe(
        """
        select
            reporting_month,
            raw_transaction_count,
            stg_transaction_count,
            fact_transaction_count,
            obt_transaction_count,
            mart_total_transaction_count,
            raw_settled_volume_usd,
            stg_settled_volume_usd,
            fact_settled_volume_usd,
            obt_settled_volume_usd,
            mart_settled_volume_usd,
            reconciliation_status
        from mart_reconciliation_status
        order by reporting_month
        """
    )

