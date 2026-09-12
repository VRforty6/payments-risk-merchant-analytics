-- 02_create_tables.sql
-- Schemas
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'staging')
    EXEC('CREATE SCHEMA staging');
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'dw')
    EXEC('CREATE SCHEMA dw');
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'rpt')
    EXEC('CREATE SCHEMA rpt');
GO

-- Staging tables (mirror CSV)
IF OBJECT_ID('staging.Countries', 'U') IS NULL
CREATE TABLE staging.Countries (
    country_id VARCHAR(10) PRIMARY KEY,
    country_name VARCHAR(100),
    region VARCHAR(50),
    currency_code VARCHAR(10),
    market_display_name VARCHAR(100)
);
GO

IF OBJECT_ID('staging.Merchants', 'U') IS NULL
CREATE TABLE staging.Merchants (
    merchant_id VARCHAR(20) PRIMARY KEY,
    merchant_name VARCHAR(100),
    category VARCHAR(50),
    risk_tier VARCHAR(20),
    base_decline_prob FLOAT,
    base_chargeback_prob FLOAT,
    base_refund_prob FLOAT,
    amount_mean FLOAT,
    amount_std FLOAT,
    anomaly_type VARCHAR(50),
    merchant_display_name VARCHAR(120)
);
GO

IF OBJECT_ID('staging.Customers', 'U') IS NULL
CREATE TABLE staging.Customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(100),
    country VARCHAR(50)  -- references staging.Countries.country_id but keep as varchar for load
);
GO

IF OBJECT_ID('staging.Transactions', 'U') IS NULL
CREATE TABLE staging.Transactions (
    transaction_id VARCHAR(30) PRIMARY KEY,
    merchant_id VARCHAR(20),
    customer_id VARCHAR(20),
    timestamp DATETIME,
    amount DECIMAL(18,2),
    currency_code VARCHAR(10),
    payment_method VARCHAR(50),
    device_type VARCHAR(50),
    channel VARCHAR(50),
    country_id VARCHAR(10),
    is_approved VARCHAR(5),          -- 'True'/'False'
    decline_reason VARCHAR(100),
    is_refunded VARCHAR(5),          -- 'True'/'False'
    refund_amount DECIMAL(18,2),
    is_chargeback VARCHAR(5),        -- 'True'/'False'
    chargeback_amount DECIMAL(18,2),
    processing_fee DECIMAL(18,2)
);
GO

-- Dimension tables
IF OBJECT_ID('dw.DimDate', 'U') IS NULL
CREATE TABLE dw.DimDate (
    DateKey INT PRIMARY KEY,            -- YYYYMMDD (not identity)
    DateDate DATE,
    Year INT,
    Quarter INT,
    Month INT,
    Day INT,
    Weekday VARCHAR(10),
    IsWeekend BIT
);
GO

IF OBJECT_ID('dw.DimMerchant', 'U') IS NULL
CREATE TABLE dw.DimMerchant (
    MerchantKey INT IDENTITY(1,1) PRIMARY KEY,
    MerchantID VARCHAR(20) NOT NULL UNIQUE,
    MerchantName VARCHAR(100),
    MerchantDisplayName VARCHAR(120),
    Category VARCHAR(50),
    RiskTier VARCHAR(20),
    BaseDeclineProb FLOAT,
    BaseChargebackProb FLOAT,
    BaseRefundProb FLOAT,
    AmountMean FLOAT,
    AmountStd FLOAT,
    AnomalyType VARCHAR(50)
);
GO

IF OBJECT_ID('dw.DimCustomer', 'U') IS NULL
CREATE TABLE dw.DimCustomer (
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID VARCHAR(20) NOT NULL UNIQUE,
    CustomerName VARCHAR(100),
    Country VARCHAR(50)
);
GO

IF OBJECT_ID('dw.DimGeography', 'U') IS NULL
CREATE TABLE dw.DimGeography (
    GeographyKey INT IDENTITY(1,1) PRIMARY KEY,
    CountryID VARCHAR(10) NOT NULL UNIQUE,
    CountryName VARCHAR(100),
    MarketDisplayName VARCHAR(100),
    Region VARCHAR(50),
    CurrencyCode VARCHAR(10)
);
GO

IF OBJECT_ID('dw.DimPaymentMethod', 'U') IS NULL
CREATE TABLE dw.DimPaymentMethod (
    PaymentMethodKey INT IDENTITY(1,1) PRIMARY KEY,
    PaymentMethod VARCHAR(50) NOT NULL UNIQUE
);
GO

IF OBJECT_ID('dw.DimTransactionStatus', 'U') IS NULL
CREATE TABLE dw.DimTransactionStatus (
    TransactionStatusKey INT PRIMARY KEY,
    IsApproved BIT NOT NULL,
    DeclineReason VARCHAR(100),
    IsRefunded BIT,
    RefundAmount DECIMAL(18,2),
    IsChargeback BIT,
    ChargebackAmount DECIMAL(18,2)
);
GO

-- Fact table
IF OBJECT_ID('dw.FactTransactions', 'U') IS NULL
CREATE TABLE dw.FactTransactions (
    TransactionKey BIGINT IDENTITY(1,1) PRIMARY KEY,
    TransactionID VARCHAR(30) NOT NULL UNIQUE,
    DateKey INT NOT NULL,
    TransactionTimestamp DATETIME NOT NULL,
    MerchantKey INT NOT NULL,
    CustomerKey INT NOT NULL,
    GeographyKey INT NOT NULL,
    PaymentMethodKey INT NOT NULL,
    TransactionStatusKey INT NOT NULL,
    TransactionAmount DECIMAL(18,2) NOT NULL,
    ProcessingFee DECIMAL(18,2) NOT NULL,
    RefundAmount DECIMAL(18,2) NOT NULL,
    ChargebackAmount DECIMAL(18,2) NOT NULL,
    IsRefunded BIT NOT NULL,
    IsChargeback BIT NOT NULL,
    DeclineReason VARCHAR(100) NULL,
    DeviceType VARCHAR(50),
    Channel VARCHAR(50),
    CONSTRAINT FK_Fact_Date FOREIGN KEY (DateKey) REFERENCES dw.DimDate(DateKey),
    CONSTRAINT FK_Fact_Merchant FOREIGN KEY (MerchantKey) REFERENCES dw.DimMerchant(MerchantKey),
    CONSTRAINT FK_Fact_Customer FOREIGN KEY (CustomerKey) REFERENCES dw.DimCustomer(CustomerKey),
    CONSTRAINT FK_Fact_Geography FOREIGN KEY (GeographyKey) REFERENCES dw.DimGeography(GeographyKey),
    CONSTRAINT FK_Fact_PaymentMethod FOREIGN KEY (PaymentMethodKey) REFERENCES dw.DimPaymentMethod(PaymentMethodKey),
    CONSTRAINT FK_Fact_TransactionStatus FOREIGN KEY (TransactionStatusKey) REFERENCES dw.DimTransactionStatus(TransactionStatusKey)
);
GO

-- Add unknown member (key 0) to each dimension
-- Date dimension unknown date: insert directly (no identity)
IF NOT EXISTS (SELECT 1 FROM dw.DimDate WHERE DateKey = 0)
BEGIN
    INSERT INTO dw.DimDate (DateKey, DateDate, Year, Quarter, Month, Day, Weekday, IsWeekend)
    VALUES (0, NULL, NULL, NULL, NULL, NULL, 'Unknown', 0);
END
GO

IF NOT EXISTS (SELECT 1 FROM dw.DimMerchant WHERE MerchantKey = 0)
BEGIN
    SET IDENTITY_INSERT dw.DimMerchant ON;
    INSERT INTO dw.DimMerchant (MerchantKey, MerchantID, MerchantName, MerchantDisplayName, Category, RiskTier, BaseDeclineProb, BaseChargebackProb, BaseRefundProb, AmountMean, AmountStd, AnomalyType)
    VALUES (0, 'UNKNOWN', 'Unknown', 'Unknown Merchant', 'Unknown', 'Unknown', 0, 0, 0, 0, 0, 'Unknown');
    SET IDENTITY_INSERT dw.DimMerchant OFF;
END
GO

IF NOT EXISTS (SELECT 1 FROM dw.DimCustomer WHERE CustomerKey = 0)
BEGIN
    SET IDENTITY_INSERT dw.DimCustomer ON;
    INSERT INTO dw.DimCustomer (CustomerKey, CustomerID, CustomerName, Country)
    VALUES (0, 'UNKNOWN', 'Unknown', 'Unknown');
    SET IDENTITY_INSERT dw.DimCustomer OFF;
END
GO

IF NOT EXISTS (SELECT 1 FROM dw.DimGeography WHERE GeographyKey = 0)
BEGIN
    SET IDENTITY_INSERT dw.DimGeography ON;
    INSERT INTO dw.DimGeography (GeographyKey, CountryID, CountryName, MarketDisplayName, Region, CurrencyCode)
    VALUES (0, 'UNKNOWN', 'Unknown', 'Unknown Market', 'Unknown', 'Unknown');
    SET IDENTITY_INSERT dw.DimGeography OFF;
END
GO

IF NOT EXISTS (SELECT 1 FROM dw.DimPaymentMethod WHERE PaymentMethodKey = 0)
BEGIN
    SET IDENTITY_INSERT dw.DimPaymentMethod ON;
    INSERT INTO dw.DimPaymentMethod (PaymentMethodKey, PaymentMethod)
    VALUES (0, 'Unknown');
    SET IDENTITY_INSERT dw.DimPaymentMethod OFF;
END
GO

-- Insert the transaction status seed records used by the fact load.
IF NOT EXISTS (SELECT 1 FROM dw.DimTransactionStatus WHERE TransactionStatusKey = 0)
BEGIN
    SET IDENTITY_INSERT dw.DimTransactionStatus ON;
    INSERT INTO dw.DimTransactionStatus (
        TransactionStatusKey,
        IsApproved,
        DeclineReason,
        IsRefunded,
        RefundAmount,
        IsChargeback,
        ChargebackAmount
    )
    VALUES
        (0, 0, 'Unknown', 0, 0.00, 0, 0.00),
        (1, 1, NULL, 0, 0.00, 0, 0.00),
        (2, 0, NULL, 0, 0.00, 0, 0.00);
    SET IDENTITY_INSERT dw.DimTransactionStatus OFF;
END
GO
