-- 04_load_dimensions_and_fact.sql
USE PaymentsRiskAnalytics;
GO

PRINT 'Loading dimensions and fact...';

-- 1. Populate DimDate from distinct transaction dates
PRINT 'Inserting into DimDate...';
INSERT INTO dw.DimDate (DateKey, DateDate, Year, Quarter, Month, Day, Weekday, IsWeekend)
SELECT DISTINCT
    CONVERT(int, CONVERT(char(8), CAST([timestamp] AS DATE), 112)) AS DateKey,
    CAST([timestamp] AS DATE) AS DateDate,
    YEAR(CAST([timestamp] AS DATE)) AS Year,
    DATEPART(QUARTER, CAST([timestamp] AS DATE)) AS Quarter,
    MONTH(CAST([timestamp] AS DATE)) AS Month,
    DAY(CAST([timestamp] AS DATE)) AS Day,
    DATENAME(WEEKDAY, CAST([timestamp] AS DATE)) AS Weekday,
    CASE WHEN DATEPART(WEEKDAY, CAST([timestamp] AS DATE)) IN (1,7) THEN 1 ELSE 0 END AS IsWeekend
FROM staging.Transactions
WHERE [timestamp] IS NOT NULL
AND NOT EXISTS (SELECT 1 FROM dw.DimDate d WHERE d.DateKey = CONVERT(int, CONVERT(char(8), CAST([timestamp] AS DATE), 112)));
PRINT 'Inserted ' + CAST(@@ROWCOUNT AS varchar(20)) + ' rows into DimDate';
GO

-- 2. Populate DimGeography from staging.Countries
PRINT 'Inserting into DimGeography...';
INSERT INTO dw.DimGeography (CountryID, CountryName, MarketDisplayName, Region, CurrencyCode)
SELECT DISTINCT
    c.country_id,
    c.country_name,
    COALESCE(
        NULLIF(c.market_display_name, ''),
        CONCAT(c.region, ' Market ', RIGHT('00' + CAST(COALESCE(TRY_CONVERT(int, REPLACE(c.country_id, 'CO', '')), 0) AS varchar(10)), 2))
    ) AS MarketDisplayName,
    c.region,
    c.currency_code
FROM staging.Countries c
WHERE NOT EXISTS (SELECT 1 FROM dw.DimGeography g WHERE g.CountryID = c.country_id);
PRINT 'Inserted ' + CAST(@@ROWCOUNT AS varchar(20)) + ' rows into DimGeography';
GO

-- 3. Populate DimPaymentMethod from distinct payment_method in transactions
PRINT 'Inserting into DimPaymentMethod...';
INSERT INTO dw.DimPaymentMethod (PaymentMethod)
SELECT DISTINCT payment_method
FROM staging.Transactions t
WHERE NOT EXISTS (SELECT 1 FROM dw.DimPaymentMethod p WHERE p.PaymentMethod = t.payment_method);
PRINT 'Inserted ' + CAST(@@ROWCOUNT AS varchar(20)) + ' rows into DimPaymentMethod';
GO

-- 4. Populate DimCustomer
PRINT 'Inserting into DimCustomer...';
INSERT INTO dw.DimCustomer (CustomerID, CustomerName, Country)
SELECT DISTINCT
    c.customer_id,
    c.customer_name,
    c.country
FROM staging.Customers c
WHERE NOT EXISTS (SELECT 1 FROM dw.DimCustomer cu WHERE cu.CustomerID = c.customer_id);
PRINT 'Inserted ' + CAST(@@ROWCOUNT AS varchar(20)) + ' rows into DimCustomer';
GO

-- 5. Populate DimMerchant
PRINT 'Inserting into DimMerchant...';
INSERT INTO dw.DimMerchant (MerchantID, MerchantName, MerchantDisplayName, Category, RiskTier, BaseDeclineProb, BaseChargebackProb, BaseRefundProb, AmountMean, AmountStd, AnomalyType)
SELECT DISTINCT
    m.merchant_id,
    m.merchant_name,
    COALESCE(
        NULLIF(m.merchant_display_name, ''),
        CONCAT(
            CASE merchant_num.MerchantNumber % 12
                WHEN 0 THEN 'Aster'
                WHEN 1 THEN 'Beacon'
                WHEN 2 THEN 'Cedar'
                WHEN 3 THEN 'Ember'
                WHEN 4 THEN 'Harbor'
                WHEN 5 THEN 'Keystone'
                WHEN 6 THEN 'Lumen'
                WHEN 7 THEN 'Meridian'
                WHEN 8 THEN 'Northstar'
                WHEN 9 THEN 'Prairie'
                WHEN 10 THEN 'Summit'
                ELSE 'Veridian'
            END,
            ' ',
            CASE LOWER(m.category)
                WHEN 'retail' THEN CASE merchant_num.MerchantNumber % 4 WHEN 0 THEN 'Goods' WHEN 1 THEN 'Supply' WHEN 2 THEN 'Market' ELSE 'Trading' END
                WHEN 'restaurant' THEN CASE merchant_num.MerchantNumber % 4 WHEN 0 THEN 'Table' WHEN 1 THEN 'Kitchen' WHEN 2 THEN 'Bistro' ELSE 'Pantry' END
                WHEN 'travel' THEN CASE merchant_num.MerchantNumber % 4 WHEN 0 THEN 'Voyages' WHEN 1 THEN 'Routes' WHEN 2 THEN 'Journey' ELSE 'Transit' END
                WHEN 'electronics' THEN CASE merchant_num.MerchantNumber % 4 WHEN 0 THEN 'Devices' WHEN 1 THEN 'Circuit' WHEN 2 THEN 'Signal' ELSE 'Systems' END
                WHEN 'clothing' THEN CASE merchant_num.MerchantNumber % 4 WHEN 0 THEN 'Apparel' WHEN 1 THEN 'Textiles' WHEN 2 THEN 'Threads' ELSE 'Wardrobe' END
                WHEN 'groceries' THEN CASE merchant_num.MerchantNumber % 4 WHEN 0 THEN 'Provisions' WHEN 1 THEN 'Harvest' WHEN 2 THEN 'Basket' ELSE 'Fresh' END
                WHEN 'healthcare' THEN CASE merchant_num.MerchantNumber % 4 WHEN 0 THEN 'Care' WHEN 1 THEN 'Wellness' WHEN 2 THEN 'Clinic' ELSE 'Health' END
                WHEN 'entertainment' THEN CASE merchant_num.MerchantNumber % 4 WHEN 0 THEN 'Events' WHEN 1 THEN 'Stage' WHEN 2 THEN 'Media' ELSE 'Leisure' END
                ELSE 'Commerce'
            END,
            ' ',
            RIGHT('000' + CAST(merchant_num.MerchantNumber AS varchar(10)), 3)
        )
    ) AS MerchantDisplayName,
    m.category,
    m.risk_tier,
    m.base_decline_prob,
    m.base_chargeback_prob,
    m.base_refund_prob,
    m.amount_mean,
    m.amount_std,
    m.anomaly_type
FROM staging.Merchants m
CROSS APPLY (
    SELECT COALESCE(TRY_CONVERT(int, REPLACE(m.merchant_id, 'M', '')), 0) AS MerchantNumber
) merchant_num
WHERE NOT EXISTS (SELECT 1 FROM dw.DimMerchant dm WHERE dm.MerchantID = m.merchant_id);
PRINT 'Inserted ' + CAST(@@ROWCOUNT AS varchar(20)) + ' rows into DimMerchant';
GO

-- 6. Populate DimTransactionStatus (handled by 02_create_tables.sql)
-- Keys are intentionally simple:
--   0 = Unknown
--   1 = Approved
--   2 = Declined
GO

-- 7. Populate FactTransactions
PRINT 'Inserting into FactTransactions...';
INSERT INTO dw.FactTransactions (
    TransactionID,
    DateKey,
    TransactionTimestamp,
    MerchantKey,
    CustomerKey,
    GeographyKey,
    PaymentMethodKey,
    TransactionStatusKey,
    TransactionAmount,
    ProcessingFee,
    RefundAmount,
    ChargebackAmount,
    IsRefunded,
    IsChargeback,
    DeviceType,
    Channel
)
SELECT
    t.transaction_id,
    COALESCE(d.DateKey, 0) AS DateKey,
    t.timestamp AS TransactionTimestamp,
    COALESCE(m.MerchantKey, 0) AS MerchantKey,
    COALESCE(c.CustomerKey, 0) AS CustomerKey,
    COALESCE(g.GeographyKey, 0) AS GeographyKey,
    COALESCE(pm.PaymentMethodKey, 0) AS PaymentMethodKey,
    CASE
        WHEN LOWER(t.is_approved) = 'true' THEN 1
        WHEN LOWER(t.is_approved) = 'false' THEN 2
        ELSE 0
    END AS TransactionStatusKey,
    t.amount AS TransactionAmount,
    t.processing_fee AS ProcessingFee,
    t.refund_amount AS RefundAmount,
    t.chargeback_amount AS ChargebackAmount,
    CASE WHEN LOWER(t.is_refunded) = 'true' THEN 1 ELSE 0 END AS IsRefunded,
    CASE WHEN LOWER(t.is_chargeback) = 'true' THEN 1 ELSE 0 END AS IsChargeback,
    t.device_type AS DeviceType,
    t.channel AS Channel
FROM staging.Transactions t
LEFT JOIN dw.DimDate d
    ON d.DateKey = CONVERT(int, CONVERT(char(8), CAST(t.[timestamp] AS DATE), 112))
LEFT JOIN dw.DimMerchant m
    ON m.MerchantID = t.merchant_id
LEFT JOIN dw.DimCustomer c
    ON c.CustomerID = t.customer_id
LEFT JOIN dw.DimGeography g
    ON g.CountryID = t.country_id
LEFT JOIN dw.DimPaymentMethod pm
    ON pm.PaymentMethod = t.payment_method
WHERE NOT EXISTS (
    SELECT 1 FROM dw.FactTransactions f
    WHERE f.TransactionID = t.transaction_id
);
PRINT 'Inserted ' + CAST(@@ROWCOUNT AS varchar(20)) + ' rows into FactTransactions';
GO
