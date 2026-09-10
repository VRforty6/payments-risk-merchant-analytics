USE PaymentsRiskAnalytics;
GO
-- sql/ddl/03_create_staging_tables.sql
-- Drop existing staging tables if they exist (for idempotency in development)
IF OBJECT_ID('stg.Merchants', 'U') IS NOT NULL
    DROP TABLE stg.Merchants;
IF OBJECT_ID('stg.Customers', 'U') IS NOT NULL
    DROP TABLE stg.Customers;
IF OBJECT_ID('stg.Countries', 'U') IS NOT NULL
    DROP TABLE stg.Countries;
IF OBJECT_ID('stg.Transactions', 'U') IS NOT NULL
    DROP TABLE stg.Transactions;

CREATE TABLE stg.Merchants (
    merchant_id VARCHAR(10) NOT NULL,
    merchant_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    risk_tier VARCHAR(10) NOT NULL,
    base_decline_prob DECIMAL(5,4) NOT NULL,
    base_chargeback_prob DECIMAL(5,4) NOT NULL,
    base_refund_prob DECIMAL(5,4) NOT NULL,
    amount_mean DECIMAL(10,2) NOT NULL,
    amount_std DECIMAL(10,2) NOT NULL,
    merchant_display_name VARCHAR(120) NULL
);

CREATE TABLE stg.Customers (
    customer_id VARCHAR(15) NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL
);

CREATE TABLE stg.Countries (
    country_id VARCHAR(5) NOT NULL,
    country_name VARCHAR(100) NOT NULL,
    region VARCHAR(50) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    market_display_name VARCHAR(100) NULL
);

CREATE TABLE stg.Transactions (
    transaction_id VARCHAR(20) NOT NULL,
    merchant_id VARCHAR(10) NOT NULL,
    customer_id VARCHAR(15) NOT NULL,
    timestamp DATETIME2 NOT NULL,
    amount DECIMAL(18,2) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    payment_method VARCHAR(20) NOT NULL,
    device_type VARCHAR(10) NOT NULL,
    channel VARCHAR(10) NOT NULL,
    country_id VARCHAR(5) NOT NULL,
    is_approved BIT NOT NULL,
    decline_reason VARCHAR(50) NULL,
    is_refunded BIT NOT NULL,
    refund_amount DECIMAL(18,2) NOT NULL,
    is_chargeback BIT NOT NULL,
    chargeback_amount DECIMAL(18,2) NOT NULL,
    processing_fee DECIMAL(10,2) NOT NULL
);

PRINT 'Staging tables created.';
GO
