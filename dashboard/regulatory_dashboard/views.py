import pandas as pd
import streamlit as st


def render_header() -> None:
    st.title("Regulatory Reporting Command Center")
    st.caption(
        "Self-serve view over governed Snowflake marts. "
        "Metric logic is defined upstream in dbt models, not in the dashboard."
    )


def render_sidebar_filters(report_df: pd.DataFrame) -> pd.DataFrame:
    st.sidebar.header("Filters")

    status_options = ["ALL"] + sorted(report_df["REPORT_STATUS"].dropna().unique().tolist())
    selected_status = st.sidebar.selectbox("Report status", status_options)

    entity_options = ["ALL"] + sorted(report_df["LEGAL_ENTITY_NAME"].dropna().unique().tolist())
    selected_entity = st.sidebar.selectbox("Legal entity", entity_options)

    filtered_df = report_df.copy()

    if selected_status != "ALL":
        filtered_df = filtered_df[filtered_df["REPORT_STATUS"] == selected_status]

    if selected_entity != "ALL":
        filtered_df = filtered_df[filtered_df["LEGAL_ENTITY_NAME"] == selected_entity]

    return filtered_df


def render_summary_metrics(filtered_df: pd.DataFrame) -> None:
    total_volume = filtered_df["REPORTABLE_SETTLED_VOLUME_USD"].sum()
    total_transactions = filtered_df["TOTAL_TRANSACTION_COUNT"].sum()
    active_customers = filtered_df["ACTIVE_CUSTOMER_COUNT"].sum()
    blocked_rows = (filtered_df["REPORT_STATUS"] == "BLOCKED").sum()

    col1, col2, col3, col4 = st.columns(4)
    col1.metric("Settled Volume USD", f"${total_volume:,.0f}")
    col2.metric("Total Transactions", f"{total_transactions:,.0f}")
    col3.metric("Active Customers", f"{active_customers:,.0f}")
    col4.metric("Blocked Report Rows", f"{blocked_rows:,.0f}")


def render_report_status_distribution(filtered_df: pd.DataFrame) -> None:
    st.subheader("Report Status Distribution")

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

