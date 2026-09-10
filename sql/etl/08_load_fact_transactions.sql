USE PaymentsRiskAnalytics;
GO
-- sql/etl/08_load_fact_transactions.sql
-- Load fact table from staging, joining with dimensions.
-- We will truncate and reload the fact table (full load).

TRUNCATE TABLE dw.FactTransactions;

-- Insert into fact table
INSERT INTO dw.FactTransactions (
    TransactionID,
    DateKey,
    TimeKey,
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
    Channel,
    DeclineReason,
    TransactionTimestamp
)
SELECT
    st.transaction_id,
    -- DateKey: we can compute as YYYYMMDD and match to DimDate.DateKey
    CONVERT(int, CONVERT(varchar(8), st.transaction_datetime, 112)) AS DateKey,
    -- TimeKey: we'll store the time part as time(0)
    CAST(st.transaction_datetime AS time(0)) AS TimeKey,
    -- MerchantKey: lookup from DimMerchant by merchant_id
    ISNULL(dm.MerchantKey, 0),
    -- CustomerKey: lookup from DimCustomer by customer_id
    ISNULL(dc.CustomerKey, 0),
    -- GeographyKey: we need to get geography from the transaction's country.
    -- The transaction has transaction_country (which is a country code? In the CSV it's transaction_country, which is a country code like 'US').
    -- We have DimGeography that we populated from StgCountries (which has country_code, country_name, region, currency_code).
    -- We'll join on CountryID = transaction_country.
    ISNULL(dg.GeographyKey, 0),
    -- PaymentMethodKey: lookup from DimPaymentMethod by payment_method
    ISNULL(dp.PaymentMethodKey, 0),
    -- TransactionStatusKey: lookup from DimTransactionStatus by transaction_status
    ISNULL(ds.TransactionStatusKey, 0),
    st.transaction_amount,
    st.processing_fee,
    st.refund_amount,
    st.chargeback_amount,
    st.is_refunded,
    st.is_chargeback,
    st.device_type,
    st.channel,
    st.decline_reason,
    st.transaction_datetime
FROM stg.StgTransactions st
LEFT JOIN dw.DimMerchant dm ON st.merchant_id = dm.MerchantID
LEFT JOIN dw.DimCustomer dc ON st.customer_id = dc.CustomerID
LEFT JOIN dw.DimGeography dg ON st.transaction_country = dg.CountryID
LEFT JOIN dw.DimPaymentMethod dp ON st.payment_method = dp.PaymentMethod
LEFT JOIN dw.DimTransactionStatus ds ON st.transaction_status = ds.Status
WHERE 1=1;
-- Note: we are using LEFT JOIN and replacing NULL with 0 (unknown member) via ISNULL.

PRINT 'Fact table loaded with ' + CAST(@@ROWCOUNT AS VARCHAR) + ' rows.';
GO