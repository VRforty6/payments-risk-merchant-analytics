USE PaymentsRiskAnalytics;
GO
-- sql/ddl/05_create_fact_transactions.sql
-- Drop fact table if exists
IF OBJECT_ID('dw.FactTransactions', 'U') IS NOT NULL
    DROP TABLE dw.FactTransactions;

-- Fact table for transactions
CREATE TABLE dw.FactTransactions (
    TransactionKey BIGINT IDENTITY(1,1) PRIMARY KEY,
    TransactionID VARCHAR(20) NOT NULL,   -- Business key from source
    DateKey INT NOT NULL,                 -- Foreign key to DimDate
    TimeKey INT NULL,                     -- Optional: time of day as HHMMSS or separate time fields; we can also store time as separate columns
    -- Instead of TimeKey, we can store the time portion as separate fields or just use the timestamp.
    -- According to requirements: TimeKey or transaction time fields.
    -- We'll store the time as separate fields: Hour, Minute, Second? Or just keep the timestamp and derive.
    -- Let's store the time as a time(0) and also keep the timestamp for completeness.
    TransactionTime TIME(0) NULL,
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
    DeviceType VARCHAR(20) NULL,
    Channel VARCHAR(20) NULL,
    DeclineReason VARCHAR(50) NULL,
    TransactionTimestamp DATETIME NOT NULL,

    -- Foreign key constraints
    CONSTRAINT FK_FactTransactions_Date FOREIGN KEY (DateKey) REFERENCES dw.DimDate(DateKey),
    CONSTRAINT FK_FactTransactions_Merchant FOREIGN KEY (MerchantKey) REFERENCES dw.DimMerchant(MerchantKey),
    CONSTRAINT FK_FactTransactions_Customer FOREIGN KEY (CustomerKey) REFERENCES dw.DimCustomer(CustomerKey),
    CONSTRAINT FK_FactTransactions_Geography FOREIGN KEY (GeographyKey) REFERENCES dw.DimGeography(GeographyKey),
    CONSTRAINT FK_FactTransactions_PaymentMethod FOREIGN KEY (PaymentMethodKey) REFERENCES dw.DimPaymentMethod(PaymentMethodKey),
    CONSTRAINT FK_FactTransactions_TransactionStatus FOREIGN KEY (TransactionStatusKey) REFERENCES dw.DimTransactionStatus(TransactionStatusKey)
);

-- Indexes for performance
CREATE NONCLUSTERED INDEX IX_FactTransactions_TransactionID ON dw.FactTransactions(TransactionID);
CREATE NONCLUSTERED INDEX IX_FactTransactions_DateKey ON dw.FactTransactions(DateKey);
CREATE NONCLUSTERED INDEX IX_FactTransactions_MerchantKey ON dw.FactTransactions(MerchantKey);
CREATE NONCLUSTERED INDEX IX_FactTransactions_CustomerKey ON dw.FactTransactions(CustomerKey);
-- Additional indexes as needed for reporting queries.

PRINT 'Fact table created.';
GO