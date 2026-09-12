# Architecture Overview

Payments Risk & Merchant Analytics is a reproducible portfolio project for synthetic payment behavior, merchant risk analysis, and Power BI reporting.

## Data Flow

```text
Python synthetic generator
        |
Generated CSV files
        |
Python validation
        |
SQL Server staging schema
        |
SQL Server dimensional dw schema
        |
Reporting views and validation SQL
        |
Power BI Import semantic model
        |
Three visible dashboard pages
```

The Python generator creates reproducible synthetic merchants, customers, markets, and transaction attempts. The CSV files are loaded into the SQL Server `staging` schema, then transformed into a star schema in `dw`.

## Warehouse Model

`dw.FactTransactions` contains one row per payment transaction attempt and is related to these seven imported Power BI tables:

- `dw.DimCustomer`
- `dw.DimDate`
- `dw.DimGeography`
- `dw.DimMerchant`
- `dw.DimPaymentMethod`
- `dw.DimTransactionStatus`
- `dw.FactTransactions`

Reporting views support SQL analysis and validation. Power BI imports the seven `dw` tables directly from SQL Server using Windows authentication and Import mode. The PBIP project stores the report definition as PBIR and the semantic model as TMDL for source control and review.

## Power BI Report

The current report has three visible production pages:

1. Executive Overview
2. Merchant Risk
3. Customer & Payment Analysis

It also contains a hidden `Validation Measures` page used to reconcile core DAX measures with SQL baselines. The report pages are 1920 × 1080 and use a consistent Enterprise BI Dark visual system.

All entities and activity are synthetic. The predefined merchant `RiskTier` is generated metadata, not an externally validated risk classification or behavioral risk score.
