-- 03_create_raw_tables.sql
-- Purpose:
-- Create raw source tables for the AI-ready regulatory data mart.
-- These tables mimic upstream systems owned by Engineering, Compliance,
-- Legal, and Business Operations.

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE REG_ANALYTICS_WH;
USE DATABASE REGULATORY_ANALYTICS;
USE SCHEMA RAW;

CREATE OR REPLACE TABLE RAW_LEGAL_ENTITIES (
    legal_entity_id STRING,
    legal_entity_name STRING,
    entity_country_code STRING,
    entity_type STRING,
    is_active BOOLEAN,
    source_system STRING,
    loaded_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE RAW_JURISDICTIONS (
    jurisdiction_code STRING,
    jurisdiction_name STRING,
    region STRING,
    is_high_risk BOOLEAN,
    source_system STRING,
    loaded_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE RAW_CUSTOMERS (
    customer_id STRING,
    customer_type STRING,
    customer_country_code STRING,
    risk_rating STRING,
    kyc_status STRING,
    onboarding_date DATE,
    source_system STRING,
    loaded_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE RAW_CUSTOMER_ENTITY_ASSIGNMENTS (
    customer_id STRING,
    legal_entity_id STRING,
    assignment_reason STRING,
    valid_from DATE,
    valid_to DATE,
    source_system STRING,
    loaded_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE RAW_TRANSACTIONS (
    transaction_id STRING,
    customer_id STRING,
    transaction_timestamp TIMESTAMP_NTZ,
    asset_symbol STRING,
    transaction_type STRING,
    transaction_status STRING,
    gross_usd_amount NUMBER(18, 2),
    fee_usd_amount NUMBER(18, 2),
    jurisdiction_code STRING,
    source_system STRING,
    loaded_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE RAW_REGULATORY_RULES (
    rule_id STRING,
    legal_entity_id STRING,
    jurisdiction_code STRING,
    metric_name STRING,
    rule_description STRING,
    is_reportable BOOLEAN,
    effective_from DATE,
    effective_to DATE,
    source_system STRING,
    loaded_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

SHOW TABLES IN SCHEMA RAW;