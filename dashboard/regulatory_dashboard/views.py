import pandas as pd
import streamlit as st


def render_header() -> None:
    st.title("Regulatory Reporting Command Center")
    st.caption(
        "Self-serve view over governed Snowflake marts. "
        "Metric logic is defined upstream in dbt models, not in the dashboard."
    )


def _string_options(df: pd.DataFrame, column_name: str) -> list[str]:
    return sorted(df[column_name].dropna().astype(str).unique().tolist())


def _filter_by_string_value(df: pd.DataFrame, column_name: str, selected_value: str) -> pd.DataFrame:
    if selected_value == "ALL":
        return df

    return df[df[column_name].astype(str) == selected_value]


def render_sidebar_filters(report_df: pd.DataFrame, dq_df: pd.DataFrame) -> dict[str, str]:
    st.sidebar.header("Filters")

    month_options = ["ALL"] + _string_options(report_df, "REPORTING_MONTH")
    selected_month = st.sidebar.selectbox("Reporting month", month_options)

    entity_options = ["ALL"] + _string_options(report_df, "LEGAL_ENTITY_NAME")
    selected_entity = st.sidebar.selectbox("Legal entity", entity_options)

    status_options = ["ALL"] + sorted(report_df["REPORT_STATUS"].dropna().unique().tolist())
    selected_status = st.sidebar.selectbox("Report status", status_options)

    severity_options = ["ALL"] + sorted(dq_df["SEVERITY"].dropna().unique().tolist())
    selected_severity = st.sidebar.selectbox("DQ severity", severity_options)

    return {
        "reporting_month": selected_month,
        "legal_entity": selected_entity,
        "report_status": selected_status,
        "dq_severity": selected_severity,
    }


def filter_regulatory_report(report_df: pd.DataFrame, filters: dict[str, str]) -> pd.DataFrame:
    filtered_df = report_df.copy()

    filtered_df = _filter_by_string_value(filtered_df, "REPORTING_MONTH", filters["reporting_month"])
    filtered_df = _filter_by_string_value(filtered_df, "LEGAL_ENTITY_NAME", filters["legal_entity"])
    filtered_df = _filter_by_string_value(filtered_df, "REPORT_STATUS", filters["report_status"])

    return filtered_df


def filter_dq_exceptions(dq_df: pd.DataFrame, filters: dict[str, str]) -> pd.DataFrame:
    filtered_df = dq_df.copy()

    filtered_df = _filter_by_string_value(filtered_df, "REPORTING_MONTH", filters["reporting_month"])
    filtered_df = _filter_by_string_value(filtered_df, "LEGAL_ENTITY_NAME", filters["legal_entity"])
    filtered_df = _filter_by_string_value(filtered_df, "SEVERITY", filters["dq_severity"])

    return filtered_df


def filter_reconciliation(reconciliation_df: pd.DataFrame, filters: dict[str, str]) -> pd.DataFrame:
    filtered_df = reconciliation_df.copy()

    filtered_df = _filter_by_string_value(filtered_df, "REPORTING_MONTH", filters["reporting_month"])

    return filtered_df


def render_summary_metrics(filtered_df: pd.DataFrame) -> None:
    total_volume = filtered_df["REPORTABLE_SETTLED_VOLUME_USD"].sum()
    total_transactions = filtered_df["TOTAL_TRANSACTION_COUNT"].sum()
    active_customers = filtered_df["ACTIVE_CUSTOMER_COUNT"].sum()
    blocked_rows = (filtered_df["REPORT_STATUS"] == "BLOCKED").sum()
    cross_border_count = filtered_df["HIGH_VALUE_CROSS_BORDER_TRANSACTION_COUNT"].sum()
    cross_border_volume = filtered_df["HIGH_VALUE_CROSS_BORDER_SETTLED_VOLUME_USD"].sum()

    col1, col2, col3, col4 = st.columns(4)
    col1.metric("Settled Volume USD", f"${total_volume:,.0f}")
    col2.metric("Total Transactions", f"{total_transactions:,.0f}")
    col3.metric("Active Customers", f"{active_customers:,.0f}")
    col4.metric("Blocked Report Rows", f"{blocked_rows:,.0f}")

    review_col1, review_col2 = st.columns(2)
    review_col1.metric("High-Value Cross-Border Txns", f"{cross_border_count:,.0f}")
    review_col2.metric("High-Value Cross-Border Volume", f"${cross_border_volume:,.0f}")


def render_report_status_distribution(filtered_df: pd.DataFrame) -> None:
    st.subheader("Report Status Distribution")

    if filtered_df.empty:
        st.info("No report rows match the selected filters.")
        return

    status_counts = (
        filtered_df.groupby("REPORT_STATUS", as_index=False)
        .size()
        .rename(columns={"size": "ROW_COUNT"})
    )

    st.bar_chart(status_counts, x="REPORT_STATUS", y="ROW_COUNT")


def render_report_table(filtered_df: pd.DataFrame) -> None:
    st.subheader("Entity Monthly Regulatory Report")
    st.dataframe(filtered_df, use_container_width=True)


def render_dq_exceptions(dq_df: pd.DataFrame) -> None:
    st.subheader("Data Quality Exceptions")
    st.caption("DQ exceptions explain why reporting rows may need REVIEW or BLOCKED handling.")

    if dq_df.empty:
        st.info("No DQ exceptions match the selected filters.")
        return

    dq_col1, dq_col2 = st.columns(2)

    severity_counts = (
        dq_df.groupby("SEVERITY", as_index=False)["EXCEPTION_COUNT"]
        .sum()
        .sort_values("EXCEPTION_COUNT", ascending=False)
    )

    rule_counts = (
        dq_df.groupby("DQ_RULE_CODE", as_index=False)["EXCEPTION_COUNT"]
        .sum()
        .sort_values("EXCEPTION_COUNT", ascending=False)
    )

    with dq_col1:
        st.bar_chart(severity_counts, x="SEVERITY", y="EXCEPTION_COUNT")

    with dq_col2:
        st.bar_chart(rule_counts, x="DQ_RULE_CODE", y="EXCEPTION_COUNT")

    st.dataframe(dq_df, use_container_width=True)


def render_reconciliation(reconciliation_df: pd.DataFrame) -> None:
    st.subheader("Reconciliation Status")
    st.caption("Reconciliation compares raw, staging, core, OBT, and mart outputs by reporting month.")

    if reconciliation_df.empty:
        st.info("No reconciliation rows match the selected reporting month.")
        return

    st.dataframe(reconciliation_df, use_container_width=True)


def render_metric_definitions(metric_definitions: list[dict]) -> None:
    st.subheader("Approved Metric Definitions")
    st.caption("Machine-readable metric definitions constrain AI-assisted SQL and regulatory answers.")

    for metric in metric_definitions:
        with st.expander(metric["metric_name"]):
            st.write(metric["business_definition"])
            st.markdown("**Grain**")
            st.write(", ".join(metric.get("grain", [])))

            if metric.get("required_filters"):
                st.markdown("**Required Filters**")
                st.write(metric["required_filters"])

            if metric.get("caveats"):
                st.markdown("**Caveats**")
                st.write(metric["caveats"])

            if metric.get("human_review_required_when"):
                st.markdown("**Human Review Required When**")
                st.write(metric["human_review_required_when"])
