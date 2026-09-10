-- 05_create_views.sql
USE PaymentsRiskAnalytics;
GO

-- Drop views if they exist so the script is rerunnable.
IF OBJECT_ID('rpt.vw_merchant_daily_performance', 'V') IS NOT NULL
    DROP VIEW rpt.vw_merchant_daily_performance;
GO
IF OBJECT_ID('rpt.vw_transaction_summary', 'V') IS NOT NULL
    DROP VIEW rpt.vw_transaction_summary;
GO
IF OBJECT_ID('rpt.vw_decline_analysis', 'V') IS NOT NULL
    DROP VIEW rpt.vw_decline_analysis;
GO
IF OBJECT_ID('rpt.vw_chargeback_monitoring', 'V') IS NOT NULL
    DROP VIEW rpt.vw_chargeback_monitoring;
GO

CREATE VIEW rpt.vw_merchant_daily_performance AS
SELECT
    CAST(t.TransactionTimestamp AS DATE) AS TransactionDate,
    m.MerchantID,
    m.MerchantName,
    m.MerchantDisplayName,
    m.Category AS MerchantCategory,
    m.RiskTier,
    COUNT(*) AS TransactionCount,
    SUM(CASE WHEN ts.IsApproved = 1 THEN 1 ELSE 0 END) AS ApprovedCount,
    SUM(CASE WHEN ts.IsApproved = 0 THEN 1 ELSE 0 END) AS DeclinedCount,
    SUM(t.TransactionAmount) AS TransactionValue,
    SUM(CASE WHEN ts.IsApproved = 1 THEN t.TransactionAmount ELSE 0 END) AS ApprovedValue,
    SUM(CAST(t.IsRefunded AS int)) AS RefundCount,
    SUM(t.RefundAmount) AS RefundAmount,
    SUM(CAST(t.IsChargeback AS int)) AS ChargebackCount,
    SUM(t.ChargebackAmount) AS ChargebackAmount,
    SUM(t.ProcessingFee) AS ProcessingRevenue,
    CAST(SUM(CASE WHEN ts.IsApproved = 1 THEN 1 ELSE 0 END) AS decimal(18,6)) / NULLIF(COUNT(*), 0) AS ApprovalRate,
    CAST(SUM(CASE WHEN ts.IsApproved = 0 THEN 1 ELSE 0 END) AS decimal(18,6)) / NULLIF(COUNT(*), 0) AS DeclineRate,
    CAST(SUM(t.RefundAmount) AS decimal(18,6)) / NULLIF(SUM(t.TransactionAmount), 0) AS RefundRatio,
    CAST(SUM(t.ChargebackAmount) AS decimal(18,6)) / NULLIF(SUM(t.TransactionAmount), 0) AS ChargebackRatio
FROM dw.FactTransactions t
JOIN dw.DimMerchant m ON m.MerchantKey = t.MerchantKey
JOIN dw.DimDate d ON d.DateKey = t.DateKey
JOIN dw.DimTransactionStatus ts ON ts.TransactionStatusKey = t.TransactionStatusKey
GROUP BY
    CAST(t.TransactionTimestamp AS DATE),
    m.MerchantID,
    m.MerchantName,
    m.MerchantDisplayName,
    m.Category,
    m.RiskTier;
GO

CREATE VIEW rpt.vw_transaction_summary AS
SELECT
    CAST(t.TransactionTimestamp AS DATE) AS TransactionDate,
    COUNT(*) AS TransactionCount,
    SUM(CASE WHEN ts.IsApproved = 1 THEN 1 ELSE 0 END) AS ApprovedCount,
    SUM(CASE WHEN ts.IsApproved = 0 THEN 1 ELSE 0 END) AS DeclinedCount,
    SUM(t.TransactionAmount) AS TransactionValue,
    SUM(CASE WHEN ts.IsApproved = 1 THEN t.TransactionAmount ELSE 0 END) AS ApprovedValue,
    SUM(CAST(t.IsRefunded AS int)) AS RefundCount,
    SUM(t.RefundAmount) AS RefundAmount,
    SUM(CAST(t.IsChargeback AS int)) AS ChargebackCount,
    SUM(t.ChargebackAmount) AS ChargebackAmount,
    SUM(t.ProcessingFee) AS ProcessingRevenue,
    CAST(SUM(CASE WHEN ts.IsApproved = 1 THEN 1 ELSE 0 END) AS decimal(18,6)) / NULLIF(COUNT(*), 0) AS ApprovalRate,
    CAST(SUM(CASE WHEN ts.IsApproved = 0 THEN 1 ELSE 0 END) AS decimal(18,6)) / NULLIF(COUNT(*), 0) AS DeclineRate,
    CAST(SUM(t.RefundAmount) AS decimal(18,6)) / NULLIF(SUM(t.TransactionAmount), 0) AS RefundRatio,
    CAST(SUM(t.ChargebackAmount) AS decimal(18,6)) / NULLIF(SUM(t.TransactionAmount), 0) AS ChargebackRatio
FROM dw.FactTransactions t
JOIN dw.DimDate d ON d.DateKey = t.DateKey
JOIN dw.DimTransactionStatus ts ON ts.TransactionStatusKey = t.TransactionStatusKey
GROUP BY CAST(t.TransactionTimestamp AS DATE);
GO

CREATE VIEW rpt.vw_decline_analysis AS
SELECT
    t.DeclineReason,
    COUNT(*) AS DeclineCount,
    SUM(t.TransactionAmount) AS DeclinedValue
FROM dw.FactTransactions t
JOIN dw.DimTransactionStatus ts ON ts.TransactionStatusKey = t.TransactionStatusKey
WHERE ts.IsApproved = 0
  AND NULLIF(LTRIM(RTRIM(t.DeclineReason)), '') IS NOT NULL
GROUP BY t.DeclineReason;
GO

CREATE VIEW rpt.vw_chargeback_monitoring AS
SELECT
    CAST(t.TransactionTimestamp AS DATE) AS TransactionDate,
    m.MerchantID,
    m.MerchantName,
    m.MerchantDisplayName,
    m.Category AS MerchantCategory,
    m.RiskTier,
    COUNT(*) AS ChargebackCount,
    SUM(t.ChargebackAmount) AS TotalChargebackAmount,
    AVG(t.ChargebackAmount) AS AvgChargebackAmount,
    SUM(t.TransactionAmount) AS TotalTransactionVolume
FROM dw.FactTransactions t
JOIN dw.DimMerchant m ON m.MerchantKey = t.MerchantKey
WHERE t.IsChargeback = 1
GROUP BY
    CAST(t.TransactionTimestamp AS DATE),
    m.MerchantID,
    m.MerchantName,
    m.MerchantDisplayName,
    m.Category,
    m.RiskTier;
GO
