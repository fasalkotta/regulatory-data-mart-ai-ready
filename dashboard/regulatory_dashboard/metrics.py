from pathlib import Path

import streamlit as st
import yaml


@st.cache_data
def load_metric_definitions() -> list[dict]:
    metrics_path = Path(__file__).resolve().parents[2] / "metrics" / "metric_definitions.yml"

    with metrics_path.open("r", encoding="utf-8") as f:
        payload = yaml.safe_load(f)

    return payload["metrics"]

