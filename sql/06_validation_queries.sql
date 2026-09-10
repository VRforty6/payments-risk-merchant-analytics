-- 06_validation_queries.sql
USE PaymentsRiskAnalytics;
GO

SET NOCOUNT ON;

SELECT 'staging.Countries' AS TableName, COUNT(*) AS RecordCount FROM staging.Countries
UNION ALL
SELECT 'staging.Merchants', COUNT(*) FROM staging.Merchants
UNION ALL
SELECT 'staging.Customers', COUNT(*) FROM staging.Customers
UNION ALL
SELECT 'staging.Transactions', COUNT(*) FROM staging.Transactions
UNION ALL
SELECT 'dw.DimCustomer', COUNT(*) FROM dw.DimCustomer
UNION ALL
SELECT 'dw.DimDate', COUNT(*) FROM dw.DimDate
UNION ALL
SELECT 'dw.DimGeography', COUNT(*) FROM dw.DimGeography
UNION ALL
SELECT 'dw.DimMerchant', COUNT(*) FROM dw.DimMerchant
UNION ALL
SELECT 'dw.DimPaymentMethod', COUNT(*) FROM dw.DimPaymentMethod
UNION ALL
SELECT 'dw.DimTransactionStatus', COUNT(*) FROM dw.DimTransactionStatus
UNION ALL
SELECT 'dw.FactTransactions', COUNT(*) FROM dw.FactTransactions;
GO

DECLARE @Results TABLE (
    CheckName varchar(160) NOT NULL,
    ViolationCount bigint NOT NULL,
    Detail varchar(4000) NULL
);

INSERT @Results
SELECT 'staging.Transactions row count is not 75000',
       CASE WHEN COUNT(*) = 75000 THEN 0 ELSE 1 END,
       CAST(COUNT(*) AS varchar(40))
FROM staging.Transactions;

INSERT @Results
SELECT 'dw.FactTransactions row count is not 75000',
       CASE WHEN COUNT(*) = 75000 THEN 0 ELSE 1 END,
       CAST(COUNT(*) AS varchar(40))
FROM dw.FactTransactions;

INSERT @Results
SELECT 'Duplicate staging transaction_id', COUNT(*), NULL
FROM (
    SELECT transaction_id
    FROM staging.Transactions
    GROUP BY transaction_id
    HAVING COUNT(*) > 1
) d;

INSERT @Results
SELECT 'Duplicate fact TransactionID', COUNT(*), NULL
FROM (
    SELECT TransactionID
    FROM dw.FactTransactions
    GROUP BY TransactionID
    HAVING COUNT(*) > 1
) d;

INSERT @Results
SELECT 'Staging transaction IDs missing from fact', COUNT(*), NULL
FROM staging.Transactions s
LEFT JOIN dw.FactTransactions f ON f.TransactionID = s.transaction_id
WHERE f.TransactionID IS NULL;

INSERT @Results
SELECT 'Fact transaction IDs missing from staging', COUNT(*), NULL
FROM dw.FactTransactions f
LEFT JOIN staging.Transactions s ON s.transaction_id = f.TransactionID
WHERE s.transaction_id IS NULL;

INSERT @Results
SELECT 'Duplicate DimMerchant MerchantID', COUNT(*), NULL
FROM (SELECT MerchantID FROM dw.DimMerchant GROUP BY MerchantID HAVING COUNT(*) > 1) d;

INSERT @Results
SELECT 'Duplicate DimCustomer CustomerID', COUNT(*), NULL
FROM (SELECT CustomerID FROM dw.DimCustomer GROUP BY CustomerID HAVING COUNT(*) > 1) d;

INSERT @Results
SELECT 'Duplicate DimGeography CountryID', COUNT(*), NULL
FROM (SELECT CountryID FROM dw.DimGeography GROUP BY CountryID HAVING COUNT(*) > 1) d;

INSERT @Results
SELECT 'Duplicate DimPaymentMethod PaymentMethod', COUNT(*), NULL
FROM (SELECT PaymentMethod FROM dw.DimPaymentMethod GROUP BY PaymentMethod HAVING COUNT(*) > 1) d;

INSERT @Results
SELECT 'Duplicate DimDate DateDate excluding unknown', COUNT(*), NULL
FROM (
    SELECT DateDate
    FROM dw.DimDate
    WHERE DateKey <> 0
    GROUP BY DateDate
    HAVING COUNT(*) > 1
) d;

INSERT @Results
SELECT 'Fact rows using unknown dimension keys', COUNT(*), NULL
FROM dw.FactTransactions
WHERE DateKey = 0
   OR MerchantKey = 0
   OR CustomerKey = 0
   OR GeographyKey = 0
   OR PaymentMethodKey = 0
   OR TransactionStatusKey = 0;

INSERT @Results
SELECT 'Invalid staging is_approved values', COUNT(*), STRING_AGG(CONVERT(varchar(max), is_approved), ', ')
FROM (
    SELECT DISTINCT is_approved
    FROM staging.Transactions
    WHERE is_approved IS NULL OR is_approved NOT IN ('True', 'False')
) x;

INSERT @Results
SELECT 'Invalid staging is_refunded values', COUNT(*), STRING_AGG(CONVERT(varchar(max), is_refunded), ', ')
FROM (
    SELECT DISTINCT is_refunded
    FROM staging.Transactions
    WHERE is_refunded IS NULL OR is_refunded NOT IN ('True', 'False')
) x;

INSERT @Results
SELECT 'Invalid staging is_chargeback values', COUNT(*), STRING_AGG(CONVERT(varchar(max), is_chargeback), ', ')
FROM (
    SELECT DISTINCT is_chargeback
    FROM staging.Transactions
    WHERE is_chargeback IS NULL OR is_chargeback NOT IN ('True', 'False')
) x;

INSERT @Results
SELECT 'Invalid payment methods', COUNT(*), STRING_AGG(CONVERT(varchar(max), payment_method), ', ')
FROM (
    SELECT DISTINCT payment_method
    FROM staging.Transactions
    WHERE payment_method IS NULL
       OR payment_method NOT IN ('credit_card', 'debit_card', 'digital_wallet', 'bank_transfer')
) x;

INSERT @Results
SELECT 'Invalid device types', COUNT(*), STRING_AGG(CONVERT(varchar(max), device_type), ', ')
FROM (
    SELECT DISTINCT device_type
    FROM staging.Transactions
    WHERE device_type IS NULL
       OR device_type NOT IN ('mobile', 'desktop', 'tablet')
) x;

INSERT @Results
SELECT 'Invalid channels', COUNT(*), STRING_AGG(CONVERT(varchar(max), channel), ', ')
FROM (
    SELECT DISTINCT channel
    FROM staging.Transactions
    WHERE channel IS NULL
       OR channel NOT IN ('online', 'pos', 'in_app')
) x;

INSERT @Results
SELECT 'Invalid merchant risk tiers', COUNT(*), STRING_AGG(CONVERT(varchar(max), RiskTier), ', ')
FROM (
    SELECT DISTINCT RiskTier
    FROM dw.DimMerchant
    WHERE MerchantKey <> 0
      AND RiskTier NOT IN ('low', 'medium', 'high')
) x;

INSERT @Results
SELECT 'Invalid merchant anomaly types', COUNT(*), STRING_AGG(CONVERT(varchar(max), AnomalyType), ', ')
FROM (
    SELECT DISTINCT AnomalyType
    FROM dw.DimMerchant
    WHERE MerchantKey <> 0
      AND AnomalyType NOT IN ('normal', 'approval_rate_decline', 'chargeback_spike', 'refund_spike', 'unusual_volume_increase')
) x;

INSERT @Results
SELECT 'Unexpected NULLs in staging mandatory transaction fields', COUNT(*), NULL
FROM staging.Transactions
WHERE transaction_id IS NULL
   OR merchant_id IS NULL
   OR customer_id IS NULL
   OR [timestamp] IS NULL
   OR amount IS NULL
   OR currency_code IS NULL
   OR payment_method IS NULL
   OR country_id IS NULL
   OR is_approved IS NULL
   OR is_refunded IS NULL
   OR refund_amount IS NULL
   OR is_chargeback IS NULL
   OR chargeback_amount IS NULL
   OR processing_fee IS NULL;

INSERT @Results
SELECT 'Unexpected NULLs in fact required analytics fields', COUNT(*), NULL
FROM dw.FactTransactions
WHERE TransactionID IS NULL
   OR TransactionTimestamp IS NULL
   OR TransactionAmount IS NULL
   OR ProcessingFee IS NULL
   OR RefundAmount IS NULL
   OR ChargebackAmount IS NULL
   OR IsRefunded IS NULL
   OR IsChargeback IS NULL;

INSERT @Results
SELECT 'Negative financial values', COUNT(*), NULL
FROM dw.FactTransactions
WHERE TransactionAmount < 0
   OR ProcessingFee < 0
   OR RefundAmount < 0
   OR ChargebackAmount < 0;

INSERT @Results
SELECT 'Refunds on declined transactions', COUNT(*), NULL
FROM dw.FactTransactions f
JOIN dw.DimTransactionStatus ts ON ts.TransactionStatusKey = f.TransactionStatusKey
WHERE ts.IsApproved = 0
  AND f.IsRefunded = 1;

INSERT @Results
SELECT 'Chargebacks on declined transactions', COUNT(*), NULL
FROM dw.FactTransactions f
JOIN dw.DimTransactionStatus ts ON ts.TransactionStatusKey = f.TransactionStatusKey
WHERE ts.IsApproved = 0
  AND f.IsChargeback = 1;

INSERT @Results
SELECT 'Approved transactions with decline reason', COUNT(*), NULL
FROM dw.FactTransactions f
JOIN dw.DimTransactionStatus ts ON ts.TransactionStatusKey = f.TransactionStatusKey
WHERE ts.IsApproved = 1
  AND NULLIF(LTRIM(RTRIM(f.DeclineReason)), '') IS NOT NULL;

INSERT @Results
SELECT 'Declined transactions missing decline reason', COUNT(*), NULL
FROM dw.FactTransactions f
JOIN dw.DimTransactionStatus ts ON ts.TransactionStatusKey = f.TransactionStatusKey
WHERE ts.IsApproved = 0
  AND NULLIF(LTRIM(RTRIM(f.DeclineReason)), '') IS NULL;

INSERT @Results
SELECT 'Refund amount inconsistent with IsRefunded', COUNT(*), NULL
FROM dw.FactTransactions
WHERE (IsRefunded = 1 AND RefundAmount <= 0)
   OR (IsRefunded = 0 AND RefundAmount <> 0);

INSERT @Results
SELECT 'Chargeback amount inconsistent with IsChargeback', COUNT(*), NULL
FROM dw.FactTransactions
WHERE (IsChargeback = 1 AND ChargebackAmount <= 0)
   OR (IsChargeback = 0 AND ChargebackAmount <> 0);

INSERT @Results
SELECT 'Refund amount greater than transaction amount', COUNT(*), NULL
FROM dw.FactTransactions
WHERE RefundAmount > TransactionAmount;

INSERT @Results
SELECT 'Chargeback amount greater than transaction amount', COUNT(*), NULL
FROM dw.FactTransactions
WHERE ChargebackAmount > TransactionAmount;

INSERT @Results
SELECT 'Fact DateKey does not match TransactionTimestamp date', COUNT(*), NULL
FROM dw.FactTransactions
WHERE DateKey <> CONVERT(int, CONVERT(char(8), CAST(TransactionTimestamp AS date), 112));

SELECT CheckName, ViolationCount, Detail
FROM @Results
ORDER BY CheckName;
GO

SELECT 'TransactionAmount' AS Metric,
       SUM(CAST(s.amount AS decimal(19,2))) AS StagingTotal,
       SUM(CAST(f.TransactionAmount AS decimal(19,2))) AS FactTotal,
       SUM(CAST(f.TransactionAmount AS decimal(19,2))) - SUM(CAST(s.amount AS decimal(19,2))) AS Difference
FROM staging.Transactions s
JOIN dw.FactTransactions f ON f.TransactionID = s.transaction_id
UNION ALL
SELECT 'ProcessingFee',
       SUM(CAST(s.processing_fee AS decimal(19,2))),
       SUM(CAST(f.ProcessingFee AS decimal(19,2))),
       SUM(CAST(f.ProcessingFee AS decimal(19,2))) - SUM(CAST(s.processing_fee AS decimal(19,2)))
FROM staging.Transactions s
JOIN dw.FactTransactions f ON f.TransactionID = s.transaction_id
UNION ALL
SELECT 'RefundAmount',
       SUM(CAST(s.refund_amount AS decimal(19,2))),
       SUM(CAST(f.RefundAmount AS decimal(19,2))),
       SUM(CAST(f.RefundAmount AS decimal(19,2))) - SUM(CAST(s.refund_amount AS decimal(19,2)))
FROM staging.Transactions s
JOIN dw.FactTransactions f ON f.TransactionID = s.transaction_id
UNION ALL
SELECT 'ChargebackAmount',
       SUM(CAST(s.chargeback_amount AS decimal(19,2))),
       SUM(CAST(f.ChargebackAmount AS decimal(19,2))),
       SUM(CAST(f.ChargebackAmount AS decimal(19,2))) - SUM(CAST(s.chargeback_amount AS decimal(19,2)))
FROM staging.Transactions s
JOIN dw.FactTransactions f ON f.TransactionID = s.transaction_id;
GO
