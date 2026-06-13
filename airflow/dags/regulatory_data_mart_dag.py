from __future__ import annotations

from datetime import datetime

from airflow.decorators import dag, task
from airflow.operators.bash import BashOperator
from airflow.operators.empty import EmptyOperator


@dag(
    dag_id="regulatory_data_mart",
    description="Orchestrates the regulatory data mart dbt build and validation workflow.",
    schedule="0 6 * * *",
    start_date=datetime(2026, 6, 1),
    catchup=False,
    tags=["regulatory", "dbt", "snowflake"],
)
def regulatory_data_mart_dag():
    start = EmptyOperator(task_id="start")
    end = EmptyOperator(task_id="end")

    @task
    def validate_raw_sources() -> str:
        return "Raw source validation placeholder passed."

    run_dbt_build = BashOperator(
        task_id="run_dbt_build",
        bash_command=(
            "cd /opt/airflow/dbt && "
            "dbt build --target prod --profiles-dir /opt/airflow/dbt_profiles"
        ),
    )

    @task
    def validate_mart_outputs() -> str:
        return "Mart validation placeholder passed."

    @task
    def publish_completion_status() -> str:
        return "Regulatory data mart workflow completed."

    start >> validate_raw_sources() >> run_dbt_build >> validate_mart_outputs() >> publish_completion_status() >> end


regulatory_data_mart_dag()
