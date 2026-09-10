USE PaymentsRiskAnalytics;
GO

-- sql/tests/11_reconciliation_tests.sql
-- Reconcile the loaded staging tables to the dimensional warehouse.

SET NOCOUNT ON;

SELECT
    'Countries -> DimGeography' AS CheckName,
    (SELECT COUNT(*) FROM staging.Countries) AS StagingCount,
    (SELECT COUNT(*) FROM dw.DimGeography WHERE GeographyKey <> 0) AS WarehouseCount,
    (SELECT COUNT(*) FROM dw.DimGeography WHERE GeographyKey <> 0) - (SELECT COUNT(*) FROM staging.Countries) AS Difference;

SELECT
    'Merchants -> DimMerchant' AS CheckName,
    (SELECT COUNT(*) FROM staging.Merchants) AS StagingCount,
    (SELECT COUNT(*) FROM dw.DimMerchant WHERE MerchantKey <> 0) AS WarehouseCount,
    (SELECT COUNT(*) FROM dw.DimMerchant WHERE MerchantKey <> 0) - (SELECT COUNT(*) FROM staging.Merchants) AS Difference;

SELECT
    'Customers -> DimCustomer' AS CheckName,
    (SELECT COUNT(*) FROM staging.Customers) AS StagingCount,
    (SELECT COUNT(*) FROM dw.DimCustomer WHERE CustomerKey <> 0) AS WarehouseCount,
    (SELECT COUNT(*) FROM dw.DimCustomer WHERE CustomerKey <> 0) - (SELECT COUNT(*) FROM staging.Customers) AS Difference;

SELECT
    'Transactions -> FactTransactions' AS CheckName,
    (SELECT COUNT(*) FROM staging.Transactions) AS StagingCount,
    (SELECT COUNT(*) FROM dw.FactTransactions) AS WarehouseCount,
    (SELECT COUNT(*) FROM dw.FactTransactions) - (SELECT COUNT(*) FROM staging.Transactions) AS Difference;

SELECT
    'Staging transaction IDs missing from fact' AS CheckName,
    COUNT(*) AS Difference
FROM staging.Transactions s
LEFT JOIN dw.FactTransactions f ON f.TransactionID = s.transaction_id
WHERE f.TransactionID IS NULL;

SELECT
    'Fact transaction IDs missing from staging' AS CheckName,
    COUNT(*) AS Difference
FROM dw.FactTransactions f
LEFT JOIN staging.Transactions s ON s.transaction_id = f.TransactionID
WHERE s.transaction_id IS NULL;

SELECT
    'TransactionAmount' AS Metric,
    SUM(CAST(s.amount AS decimal(19,2))) AS StagingTotal,
    SUM(CAST(f.TransactionAmount AS decimal(19,2))) AS WarehouseTotal,
    SUM(CAST(f.TransactionAmount AS decimal(19,2))) - SUM(CAST(s.amount AS decimal(19,2))) AS Difference
FROM staging.Transactions s
JOIN dw.FactTransactions f ON f.TransactionID = s.transaction_id
UNION ALL
SELECT
    'ProcessingFee',
    SUM(CAST(s.processing_fee AS decimal(19,2))),
    SUM(CAST(f.ProcessingFee AS decimal(19,2))),
    SUM(CAST(f.ProcessingFee AS decimal(19,2))) - SUM(CAST(s.processing_fee AS decimal(19,2)))
FROM staging.Transactions s
JOIN dw.FactTransactions f ON f.TransactionID = s.transaction_id
UNION ALL
SELECT
    'RefundAmount',
    SUM(CAST(s.refund_amount AS decimal(19,2))),
    SUM(CAST(f.RefundAmount AS decimal(19,2))),
    SUM(CAST(f.RefundAmount AS decimal(19,2))) - SUM(CAST(s.refund_amount AS decimal(19,2)))
FROM staging.Transactions s
JOIN dw.FactTransactions f ON f.TransactionID = s.transaction_id
UNION ALL
SELECT
    'ChargebackAmount',
    SUM(CAST(s.chargeback_amount AS decimal(19,2))),
    SUM(CAST(f.ChargebackAmount AS decimal(19,2))),
    SUM(CAST(f.ChargebackAmount AS decimal(19,2))) - SUM(CAST(s.chargeback_amount AS decimal(19,2)))
FROM staging.Transactions s
JOIN dw.FactTransactions f ON f.TransactionID = s.transaction_id;

SELECT
    'ApprovedCount' AS Metric,
    SUM(CASE WHEN s.is_approved = 'True' THEN 1 ELSE 0 END) AS StagingCount,
    SUM(CASE WHEN ts.IsApproved = 1 THEN 1 ELSE 0 END) AS WarehouseCount,
    SUM(CASE WHEN ts.IsApproved = 1 THEN 1 ELSE 0 END) - SUM(CASE WHEN s.is_approved = 'True' THEN 1 ELSE 0 END) AS Difference
FROM staging.Transactions s
JOIN dw.FactTransactions f ON f.TransactionID = s.transaction_id
JOIN dw.DimTransactionStatus ts ON ts.TransactionStatusKey = f.TransactionStatusKey
UNION ALL
SELECT
    'DeclinedCount',
    SUM(CASE WHEN s.is_approved = 'False' THEN 1 ELSE 0 END),
    SUM(CASE WHEN ts.IsApproved = 0 THEN 1 ELSE 0 END),
    SUM(CASE WHEN ts.IsApproved = 0 THEN 1 ELSE 0 END) - SUM(CASE WHEN s.is_approved = 'False' THEN 1 ELSE 0 END)
FROM staging.Transactions s
JOIN dw.FactTransactions f ON f.TransactionID = s.transaction_id
JOIN dw.DimTransactionStatus ts ON ts.TransactionStatusKey = f.TransactionStatusKey
UNION ALL
SELECT
    'RefundCount',
    SUM(CASE WHEN s.is_refunded = 'True' THEN 1 ELSE 0 END),
    SUM(CASE WHEN f.IsRefunded = 1 THEN 1 ELSE 0 END),
    SUM(CASE WHEN f.IsRefunded = 1 THEN 1 ELSE 0 END) - SUM(CASE WHEN s.is_refunded = 'True' THEN 1 ELSE 0 END)
FROM staging.Transactions s
JOIN dw.FactTransactions f ON f.TransactionID = s.transaction_id
UNION ALL
SELECT
    'ChargebackCount',
    SUM(CASE WHEN s.is_chargeback = 'True' THEN 1 ELSE 0 END),
    SUM(CASE WHEN f.IsChargeback = 1 THEN 1 ELSE 0 END),
    SUM(CASE WHEN f.IsChargeback = 1 THEN 1 ELSE 0 END) - SUM(CASE WHEN s.is_chargeback = 'True' THEN 1 ELSE 0 END)
FROM staging.Transactions s
JOIN dw.FactTransactions f ON f.TransactionID = s.transaction_id;
GO
