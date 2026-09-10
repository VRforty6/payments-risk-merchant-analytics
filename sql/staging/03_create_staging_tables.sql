USE PaymentsRiskAnalytics;
GO
-- sql/staging/03_create_staging_tables.sql
-- Drop staging tables if they exist
IF OBJECT_ID('stg.StgMerchants', 'U') IS NOT NULL
    DROP TABLE stg.StgMerchants;
IF OBJECT_ID('stg.StgCustomers', 'U') IS NOT NULL
    DROP TABLE stg.StgCustomers;
IF OBJECT_ID('stg.StgCountries', 'U') IS NOT NULL
    DROP TABLE stg.StgCountries;
IF OBJECT_ID('stg.StgTransactions', 'U') IS NOT NULL
    DROP TABLE stg.StgTransactions;

-- Staging table for merchants (matches merchants.csv)
CREATE TABLE stg.StgMerchants (
    merchant_id VARCHAR(10) NOT NULL,
    merchant_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    merchant_country VARCHAR(50) NOT NULL,
    onboarding_date DATE NOT NULL,
    risk_tier VARCHAR(10) NOT NULL,
    expected_monthly_volume DECIMAL(18,2) NOT NULL,
    chargeback_threshold DECIMAL(18,2) NOT NULL,
    refund_threshold DECIMAL(18,2) NOT NULL,
    merchant_status VARCHAR(20) NOT NULL,
    merchant_display_name VARCHAR(120) NULL
);

-- Staging table for customers (matches customers.csv)
CREATE TABLE stg.StgCustomers (
    customer_id VARCHAR(15) NOT NULL,
    customer_country VARCHAR(50) NOT NULL,
    signup_date DATE NOT NULL,
    customer_segment VARCHAR(20) NOT NULL
);

-- Staging table for countries (matches countries.csv)
CREATE TABLE stg.StgCountries (
    country_code VARCHAR(5) NOT NULL,
    country_name VARCHAR(100) NOT NULL,
    region VARCHAR(50) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    market_display_name VARCHAR(100) NULL
);

-- Staging table for transactions (matches transactions.csv)
CREATE TABLE stg.StgTransactions (
    transaction_id VARCHAR(20) NOT NULL,
    transaction_datetime DATETIME NOT NULL,
    merchant_id VARCHAR(10) NOT NULL,
    customer_id VARCHAR(15) NOT NULL,
    transaction_country VARCHAR(5) NOT NULL,
    currency_code CHAR(3) NOT NULL,
    payment_method VARCHAR(20) NOT NULL,
    transaction_status VARCHAR(20) NOT NULL,  -- 'Approved' or 'Declined'
    decline_reason VARCHAR(50) NULL,
    transaction_amount DECIMAL(18,2) NOT NULL,
    processing_fee DECIMAL(18,2) NOT NULL,
    refund_amount DECIMAL(18,2) NOT NULL,
    chargeback_amount DECIMAL(18,2) NOT NULL,
    is_refunded BIT NOT NULL,
    is_chargeback BIT NOT NULL,
    device_type VARCHAR(20) NULL,
    channel VARCHAR(20) NULL
);

-- Note: We are preserving the source values as they are in CSV.
-- We will later clean and convert during ETL.

PRINT 'Staging tables created.';
GO
