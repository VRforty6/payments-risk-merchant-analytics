USE PaymentsRiskAnalytics;
GO
-- sql/ddl/02_create_schemas.sql
-- Create schemas if they don't exist
IF SCHEMA_ID(N'stg') IS NULL
    EXEC('CREATE SCHEMA stg');
IF SCHEMA_ID(N'dw') IS NULL
    EXEC('CREATE SCHEMA dw');
IF SCHEMA_ID(N'rpt') IS NULL
    EXEC('CREATE SCHEMA rpt');
IF SCHEMA_ID(N'audit') IS NULL
    EXEC('CREATE SCHEMA audit');
PRINT 'Schemas ensured.';
GO