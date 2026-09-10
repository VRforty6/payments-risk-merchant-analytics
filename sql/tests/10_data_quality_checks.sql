USE PaymentsRiskAnalytics;
GO

-- sql/tests/10_data_quality_checks.sql
-- Each row reports a data-quality rule and the number of violations.

SET NOCOUNT ON;

DECLARE @Results TABLE (
    CheckName varchar(160) NOT NULL,
    ViolationCount bigint NOT NULL,
    Detail varchar(4000) NULL
);

INSERT @Results
SELECT 'Duplicate fact TransactionID', COUNT(*), NULL
FROM (
    SELECT TransactionID
    FROM dw.FactTransactions
    GROUP BY TransactionID
    HAVING COUNT(*) > 1
) d;

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
SELECT 'Fact rows using unknown dimension keys', COUNT(*), NULL
FROM dw.FactTransactions
WHERE DateKey = 0
   OR MerchantKey = 0
   OR CustomerKey = 0
   OR GeographyKey = 0
   OR PaymentMethodKey = 0
   OR TransactionStatusKey = 0;

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
