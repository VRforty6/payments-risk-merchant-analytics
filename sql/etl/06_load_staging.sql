USE PaymentsRiskAnalytics;
GO
-- sql/etl/06_load_staging.sql
-- Load data from CSV files into staging tables.
-- Supply CsvPath through sqlcmd, for example:
-- sqlcmd -S <server> -d PaymentsRiskAnalytics -i sql/etl/06_load_staging.sql -v CsvPath="C:/path/to/payment-risk-analytics/data/raw/"

-- Truncate staging tables (fresh load)
TRUNCATE TABLE stg.StgMerchants;
TRUNCATE TABLE stg.StgCustomers;
TRUNCATE TABLE stg.StgCountries;
TRUNCATE TABLE stg.StgTransactions;

-- Load Merchants
BULK INSERT stg.StgMerchants
FROM '$(CsvPath)merchants.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
PRINT 'Loaded stg.StgMerchants';

-- Load Customers
BULK INSERT stg.StgCustomers
FROM '$(CsvPath)customers.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
PRINT 'Loaded stg.StgCustomers';

-- Load Countries
BULK INSERT stg.StgCountries
FROM '$(CsvPath)countries.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
PRINT 'Loaded stg.StgCountries';

-- Load Transactions
BULK INSERT stg.StgTransactions
FROM '$(CsvPath)transactions.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);
PRINT 'Loaded stg.StgTransactions';

PRINT 'Staging load completed.';
GO
