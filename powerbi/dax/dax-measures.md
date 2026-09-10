# Core DAX Measures for Payments Risk & Merchant Analytics

The PBIP semantic model currently imports the SQL tables with schema-prefixed names such as `'dw FactTransactions'`. These definitions match the model as stored in `PaymentsRiskAnalytics.SemanticModel`.

## Transactions

```DAX
Total Transactions = COUNTROWS('dw FactTransactions')
```

```DAX
Total Transaction Amount = SUM('dw FactTransactions'[TransactionAmount])
```

```DAX
Average Transaction Value = DIVIDE([Total Transaction Amount], [Total Transactions], 0)
```

```DAX
Approved Transactions =
CALCULATE(
    [Total Transactions],
    'dw DimTransactionStatus'[IsApproved] = TRUE()
)
```

```DAX
Declined Transactions =
CALCULATE(
    [Total Transactions],
    'dw DimTransactionStatus'[IsApproved] = FALSE(),
    'dw FactTransactions'[TransactionStatusKey] <> 0
)
```

```DAX
Approval Rate = DIVIDE([Approved Transactions], [Total Transactions], 0)
```

```DAX
Decline Rate = DIVIDE([Declined Transactions], [Total Transactions], 0)
```

## Refunds

```DAX
Refund Count =
CALCULATE(
    [Total Transactions],
    'dw FactTransactions'[IsRefunded] = TRUE()
)
```

```DAX
Refund Rate = DIVIDE([Refund Count], [Total Transactions], 0)
```

```DAX
Refund Amount = SUM('dw FactTransactions'[RefundAmount])
```

## Chargebacks

```DAX
Chargeback Count =
CALCULATE(
    [Total Transactions],
    'dw FactTransactions'[IsChargeback] = TRUE()
)
```

```DAX
Chargeback Rate = DIVIDE([Chargeback Count], [Total Transactions], 0)
```

```DAX
Chargeback Amount = SUM('dw FactTransactions'[ChargebackAmount])
```

## Customers

```DAX
Unique Customers = DISTINCTCOUNT('dw FactTransactions'[CustomerKey])
```

## Risk

```DAX
Active Merchants = DISTINCTCOUNT('dw FactTransactions'[MerchantKey])
```

```DAX
Merchant Risk Tier Index =
AVERAGEX(
    VALUES('dw DimMerchant'[MerchantKey]),
    SWITCH(
        SELECTEDVALUE('dw DimMerchant'[RiskTier]),
        "high", 3,
        "medium", 2,
        "low", 1,
        BLANK()
    )
)
```

## Time Intelligence

Use `'dw DimDate'[DateDate]` as the model date column. The SQL date dimension has one row per date in the transaction range plus the unknown member.

```DAX
Previous Month Transaction Amount =
CALCULATE(
    [Total Transaction Amount],
    PREVIOUSMONTH('dw DimDate'[DateDate])
)
```

```DAX
MoM Transaction Amount % =
DIVIDE(
    [Total Transaction Amount] - [Previous Month Transaction Amount],
    [Previous Month Transaction Amount],
    0
)
```

```DAX
Rolling 30 Day Transaction Amount =
CALCULATE(
    [Total Transaction Amount],
    DATESINPERIOD('dw DimDate'[DateDate], MAX('dw DimDate'[DateDate]), -30, DAY)
)
```
