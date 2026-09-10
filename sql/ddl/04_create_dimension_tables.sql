USE PaymentsRiskAnalytics;
GO
-- sql/ddl/04_create_dimension_tables.sql
-- Drop existing dimension tables if they exist
IF OBJECT_ID('dw.DimDate', 'U') IS NOT NULL
    DROP TABLE dw.DimDate;
IF OBJECT_ID('dw.DimMerchant', 'U') IS NOT NULL
    DROP TABLE dw.DimMerchant;
IF OBJECT_ID('dw.DimCustomer', 'U') IS NOT NULL
    DROP TABLE dw.DimCustomer;
IF OBJECT_ID('dw.DimGeography', 'U') IS NOT NULL
    DROP TABLE dw.DimGeography;
IF OBJECT_ID('dw.DimPaymentMethod', 'U') IS NOT NULL
    DROP TABLE dw.DimPaymentMethod;
IF OBJECT_ID('dw.DimTransactionStatus', 'U') IS NOT NULL
    DROP TABLE dw.DimTransactionStatus;

-- Date dimension
CREATE TABLE dw.DimDate (
    DateKey INT PRIMARY KEY,          -- YYYYMMDD
    Date DATE NOT NULL,
    Year INT NOT NULL,
    Quarter INT NOT NULL,
    Month INT NOT NULL,
    Day INT NOT NULL,
    Weekday VARCHAR(10) NOT NULL,     -- Monday, Tuesday, etc.
    IsWeekend BIT NOT NULL,
    -- Additional attributes can be added as needed
);

-- Merchant dimension
CREATE TABLE dw.DimMerchant (
    MerchantKey INT IDENTITY(1,1) PRIMARY KEY,
    MerchantID VARCHAR(10) NOT NULL,
    MerchantName VARCHAR(100) NOT NULL,
    MerchantDisplayName VARCHAR(120) NULL,
    Category VARCHAR(50) NOT NULL,
    RiskTier VARCHAR(10) NOT NULL,
    BaseDeclineProb DECIMAL(5,4) NOT NULL,
    BaseChargebackProb DECIMAL(5,4) NOT NULL,
    BaseRefundProb DECIMAL(5,4) NOT NULL,
    AmountMean DECIMAL(10,2) NOT NULL,
    AmountStd DECIMAL(10,2) NOT NULL,
    IsActive BIT DEFAULT 1 NOT NULL,
    ValidFrom DATE NOT NULL,
    ValidTo DATE DEFAULT '9999-12-31' NOT NULL
);

-- Customer dimension
CREATE TABLE dw.DimCustomer (
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID VARCHAR(15) NOT NULL,
    CustomerName VARCHAR(100) NOT NULL,
    Country VARCHAR(50) NOT NULL,
    IsActive BIT DEFAULT 1 NOT NULL,
    ValidFrom DATE NOT NULL,
    ValidTo DATE DEFAULT '9999-12-31' NOT NULL
);

-- Geography dimension (combines country and region info)
CREATE TABLE dw.DimGeography (
    GeographyKey INT IDENTITY(1,1) PRIMARY KEY,
    CountryID VARCHAR(5) NOT NULL,
    CountryName VARCHAR(100) NOT NULL,
    MarketDisplayName VARCHAR(100) NULL,
    Region VARCHAR(50) NOT NULL,
    CurrencyCode CHAR(3) NOT NULL
);

-- Payment method dimension
CREATE TABLE dw.DimPaymentMethod (
    PaymentMethodKey INT IDENTITY(1,1) PRIMARY KEY,
    PaymentMethod VARCHAR(20) NOT NULL,
    ApprovalRate DECIMAL(5,4) NOT NULL   -- This is from configuration, but we can store the method name and rate
);

-- Transaction status dimension
CREATE TABLE dw.DimTransactionStatus (
    TransactionStatusKey INT IDENTITY(1,1) PRIMARY KEY,
    Status VARCHAR(20) NOT NULL,         -- 'Approved', 'Declined'
    Description VARCHAR(100) NULL
);

-- Add unknown member rows (key 0) for each dimension where appropriate
-- We'll do that in the load scripts, but we can create them now if we want to keep the tables with identity insert.
-- However, it's easier to add them during load with SET IDENTITY_INSERT ON.
-- For now, we'll note that the load scripts will handle unknown members.

PRINT 'Dimension tables created.';
GO
