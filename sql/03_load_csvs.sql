-- 03_load_csvs.sql
-- Supply CsvPath through sqlcmd, for example:
-- sqlcmd -S <server> -d PaymentsRiskAnalytics -i sql/03_load_csvs.sql -v CsvPath="C:/path/to/payment-risk-analytics/data/raw/"

USE PaymentsRiskAnalytics;
GO

-- Truncate staging tables to ensure clean load
TRUNCATE TABLE staging.Countries;
TRUNCATE TABLE staging.Merchants;
TRUNCATE TABLE staging.Customers;
TRUNCATE TABLE staging.Transactions;
GO

-- Load staging.Countries
BULK INSERT staging.Countries
FROM '$(CsvPath)countries.csv'
WITH (
    FIRSTROW = 2,          -- skip header
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO

-- Load staging.Merchants
BULK INSERT staging.Merchants
FROM '$(CsvPath)merchants.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO

-- Load staging.Customers
BULK INSERT staging.Customers
FROM '$(CsvPath)customers.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO

-- Load staging.Transactions
BULK INSERT staging.Transactions
FROM '$(CsvPath)transactions.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
GO
