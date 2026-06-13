import streamlit as st

from regulatory_dashboard.data import (
    load_dq_exception_summary,
    load_reconciliation_status,
    load_regulatory_report,
)
from regulatory_dashboard.metrics import load_metric_definitions
from regulatory_dashboard.views import (
    render_dq_exceptions,
    render_header,
    render_metric_definitions,
    render_reconciliation,
    render_report_status_distribution,
    render_report_table,
    render_sidebar_filters,
    render_summary_metrics,
)


st.set_page_config(
    page_title="Regulatory Reporting Command Center",
    layout="wide",
)


def main() -> None:
    report_df = load_regulatory_report()
    dq_df = load_dq_exception_summary()
    reconciliation_df = load_reconciliation_status()
    metric_definitions = load_metric_definitions()

    render_header()
    filtered_report_df = render_sidebar_filters(report_df)
    render_summary_metrics(filtered_report_df)
    render_report_status_distribution(filtered_report_df)
    render_report_table(filtered_report_df)
    render_dq_exceptions(dq_df)
    render_reconciliation(reconciliation_df)
    render_metric_definitions(metric_definitions)


if __name__ == "__main__":
    main()

