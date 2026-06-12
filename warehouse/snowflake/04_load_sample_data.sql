-- 04_load_sample_data.sql
-- Purpose:
-- Load sample source data into the raw layer.
-- This includes valid rows plus intentional edge cases for DQ testing.

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE REG_ANALYTICS_WH;
USE DATABASE REGULATORY_ANALYTICS;
USE SCHEMA RAW;

TRUNCATE TABLE RAW_REGULATORY_RULES;
TRUNCATE TABLE RAW_TRANSACTIONS;
TRUNCATE TABLE RAW_CUSTOMER_ENTITY_ASSIGNMENTS;
TRUNCATE TABLE RAW_CUSTOMERS;
TRUNCATE TABLE RAW_JURISDICTIONS;
TRUNCATE TABLE RAW_LEGAL_ENTITIES;

INSERT INTO RAW_LEGAL_ENTITIES (
    legal_entity_id,
    legal_entity_name,
    entity_country_code,
    entity_type,
    is_active,
    source_system
)
VALUES
    ('LE_UK', 'Coinbase UK Ltd', 'GB', 'OPERATING_ENTITY', TRUE, 'legal_entity_registry'),
    ('LE_IE', 'Coinbase Ireland Ltd', 'IE', 'OPERATING_ENTITY', TRUE, 'legal_entity_registry'),
    ('LE_DE', 'Coinbase Germany GmbH', 'DE', 'OPERATING_ENTITY', TRUE, 'legal_entity_registry'),
    ('LE_ARCHIVE', 'Archived EU Entity', 'IE', 'LEGACY_ENTITY', FALSE, 'legal_entity_registry');

INSERT INTO RAW_JURISDICTIONS (
    jurisdiction_code,
    jurisdiction_name,
    region,
    is_high_risk,
    source_system
)
VALUES
    ('GB', 'United Kingdom', 'Europe', FALSE, 'compliance_reference'),
    ('IE', 'Ireland', 'Europe', FALSE, 'compliance_reference'),
    ('DE', 'Germany', 'Europe', FALSE, 'compliance_reference'),
    ('FR', 'France', 'Europe', FALSE, 'compliance_reference'),
    ('NG', 'Nigeria', 'Africa', TRUE, 'compliance_reference'),
    ('RU', 'Russia', 'Europe/Asia', TRUE, 'compliance_reference');

INSERT INTO RAW_CUSTOMERS (
    customer_id,
    customer_type,
    customer_country_code,
    risk_rating,
    kyc_status,
    onboarding_date,
    source_system
)
VALUES
    ('CUST_001', 'RETAIL', 'GB', 'LOW', 'APPROVED', '2025-12-15', 'customer_master'),
    ('CUST_002', 'RETAIL', 'IE', 'MEDIUM', 'APPROVED', '2026-01-20', 'customer_master'),
    ('CUST_003', 'INSTITUTIONAL', 'DE', 'LOW', 'APPROVED', '2026-02-02', 'customer_master'),
    ('CUST_004', 'RETAIL', 'FR', 'HIGH', 'APPROVED', '2026-02-14', 'customer_master'),
    ('CUST_005', 'RETAIL', 'GB', 'MEDIUM', 'PENDING', '2026-03-05', 'customer_master'),
    ('CUST_006', 'INSTITUTIONAL', 'IE', 'HIGH', 'APPROVED', '2026-03-18', 'customer_master'),
    ('CUST_007', 'RETAIL', 'NG', 'HIGH', 'APPROVED', '2026-04-01', 'customer_master'),
    ('CUST_008', 'RETAIL', 'DE', 'LOW', 'REJECTED', '2026-04-11', 'customer_master'),
    ('CUST_009', 'RETAIL', 'GB', 'LOW', 'APPROVED', '2026-04-20', 'customer_master'),
    ('CUST_010', 'INSTITUTIONAL', 'IE', 'MEDIUM', 'APPROVED', '2026-04-25', 'customer_master');

INSERT INTO RAW_CUSTOMER_ENTITY_ASSIGNMENTS (
    customer_id,
    legal_entity_id,
    assignment_reason,
    valid_from,
    valid_to,
    source_system
)
VALUES
    ('CUST_001', 'LE_UK', 'country_of_residence', '2025-12-15', NULL, 'entity_assignment_service'),
    ('CUST_002', 'LE_IE', 'country_of_residence', '2026-01-20', NULL, 'entity_assignment_service'),
    ('CUST_003', 'LE_DE', 'country_of_residence', '2026-02-02', NULL, 'entity_assignment_service'),
    ('CUST_004', 'LE_IE', 'eu_customer_served_by_ireland', '2026-02-14', NULL, 'entity_assignment_service'),
    ('CUST_005', 'LE_UK', 'country_of_residence', '2026-03-05', NULL, 'entity_assignment_service'),
    ('CUST_006', 'LE_IE', 'country_of_residence', '2026-03-18', NULL, 'entity_assignment_service'),
    ('CUST_007', 'LE_IE', 'international_customer_served_by_ireland', '2026-04-01', NULL, 'entity_assignment_service'),
    ('CUST_008', 'LE_DE', 'country_of_residence', '2026-04-11', NULL, 'entity_assignment_service'),
    ('CUST_009', 'LE_UK', 'country_of_residence', '2026-04-20', NULL, 'entity_assignment_service'),
    ('CUST_010', 'LE_IE', 'country_of_residence', '2026-04-25', NULL, 'entity_assignment_service');

INSERT INTO RAW_REGULATORY_RULES (
    rule_id,
    legal_entity_id,
    jurisdiction_code,
    metric_name,
    rule_description,
    is_reportable,
    effective_from,
    effective_to,
    source_system
)
VALUES
    ('RULE_001', 'LE_UK', 'GB', 'REPORTABLE_SETTLED_VOLUME_USD', 'Settled customer transactions for Coinbase UK monthly reporting.', TRUE, '2026-01-01', NULL, 'regulatory_policy_registry'),
    ('RULE_002', 'LE_IE', 'IE', 'REPORTABLE_SETTLED_VOLUME_USD', 'Settled customer transactions for Coinbase Ireland monthly reporting.', TRUE, '2026-01-01', NULL, 'regulatory_policy_registry'),
    ('RULE_003', 'LE_DE', 'DE', 'REPORTABLE_SETTLED_VOLUME_USD', 'Settled customer transactions for Coinbase Germany monthly reporting.', TRUE, '2026-01-01', NULL, 'regulatory_policy_registry'),
    ('RULE_004', 'LE_IE', 'FR', 'REPORTABLE_SETTLED_VOLUME_USD', 'French customers served by Coinbase Ireland are included in Ireland EU reporting.', TRUE, '2026-01-01', NULL, 'regulatory_policy_registry'),
    ('RULE_005', 'LE_IE', 'NG', 'HIGH_RISK_JURISDICTION_VOLUME_USD', 'High-risk jurisdiction volume requires review before sign-off.', TRUE, '2026-01-01', NULL, 'regulatory_policy_registry');

INSERT INTO RAW_TRANSACTIONS (
    transaction_id,
    customer_id,
    transaction_timestamp,
    asset_symbol,
    transaction_type,
    transaction_status,
    gross_usd_amount,
    fee_usd_amount,
    jurisdiction_code,
    source_system
)
VALUES
    ('TXN_0001', 'CUST_001', '2026-05-01 09:15:00', 'BTC', 'BUY', 'SETTLED', 1250.00, 7.50, 'GB', 'exchange_transactions'),
    ('TXN_0002', 'CUST_001', '2026-05-02 10:00:00', 'ETH', 'SELL', 'SETTLED', 800.00, 4.80, 'GB', 'exchange_transactions'),
    ('TXN_0003', 'CUST_002', '2026-05-02 12:30:00', 'BTC', 'BUY', 'SETTLED', 2500.00, 15.00, 'IE', 'exchange_transactions'),
    ('TXN_0004', 'CUST_003', '2026-05-03 11:10:00', 'SOL', 'BUY', 'SETTLED', 12000.00, 72.00, 'DE', 'exchange_transactions'),
    ('TXN_0005', 'CUST_004', '2026-05-03 14:45:00', 'ETH', 'BUY', 'SETTLED', 6500.00, 39.00, 'FR', 'exchange_transactions'),
    ('TXN_0006', 'CUST_005', '2026-05-04 08:20:00', 'BTC', 'BUY', 'SETTLED', 900.00, 5.40, 'GB', 'exchange_transactions'),
    ('TXN_0007', 'CUST_006', '2026-05-04 16:00:00', 'USDC', 'SELL', 'SETTLED', 45000.00, 135.00, 'IE', 'exchange_transactions'),
    ('TXN_0008', 'CUST_007', '2026-05-05 09:40:00', 'BTC', 'BUY', 'SETTLED', 15000.00, 90.00, 'NG', 'exchange_transactions'),
    ('TXN_0009', 'CUST_008', '2026-05-05 11:00:00', 'ETH', 'BUY', 'SETTLED', 750.00, 4.50, 'DE', 'exchange_transactions'),
    ('TXN_0010', 'CUST_009', '2026-05-06 13:25:00', 'BTC', 'SELL', 'PENDING', 3000.00, 0.00, 'GB', 'exchange_transactions'),
    ('TXN_0011', 'CUST_010', '2026-05-06 15:10:00', 'ETH', 'BUY', 'FAILED', 2000.00, 0.00, 'IE', 'exchange_transactions'),
    ('TXN_0012', 'CUST_010', '2026-05-07 17:35:00', 'SOL', 'BUY', 'SETTLED', 9800.00, 58.80, 'IE', 'exchange_transactions'),

    -- Intentional DQ cases:
    -- Duplicate transaction id.
    ('TXN_0003', 'CUST_002', '2026-05-02 12:31:00', 'BTC', 'BUY', 'SETTLED', 2500.00, 15.00, 'IE', 'exchange_transactions'),

    -- Missing customer/entity assignment.
    ('TXN_0013', 'CUST_999', '2026-05-08 12:00:00', 'BTC', 'BUY', 'SETTLED', 1100.00, 6.60, 'GB', 'exchange_transactions'),

    -- Invalid negative amount.
    ('TXN_0014', 'CUST_001', '2026-05-08 13:00:00', 'ETH', 'SELL', 'SETTLED', -300.00, -1.80, 'GB', 'exchange_transactions');

SELECT 'RAW_LEGAL_ENTITIES' AS table_name, COUNT(*) AS row_count FROM RAW_LEGAL_ENTITIES
UNION ALL
SELECT 'RAW_JURISDICTIONS', COUNT(*) FROM RAW_JURISDICTIONS
UNION ALL
SELECT 'RAW_CUSTOMERS', COUNT(*) FROM RAW_CUSTOMERS
UNION ALL
SELECT 'RAW_CUSTOMER_ENTITY_ASSIGNMENTS', COUNT(*) FROM RAW_CUSTOMER_ENTITY_ASSIGNMENTS
UNION ALL
SELECT 'RAW_REGULATORY_RULES', COUNT(*) FROM RAW_REGULATORY_RULES
UNION ALL
SELECT 'RAW_TRANSACTIONS', COUNT(*) FROM RAW_TRANSACTIONS;