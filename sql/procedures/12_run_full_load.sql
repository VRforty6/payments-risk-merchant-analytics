USE PaymentsRiskAnalytics;
GO
-- sql/procedures/12_run_full_load.sql
-- Stored procedure to orchestrate the full ETL load.
-- This procedure provides a wrapper to run the ETL steps in the correct order.
-- Note: The actual work is done by the individual scripts.
-- This procedure can be extended to dynamically execute the scripts, but for simplicity,
-- it prints the recommended execution order.

IF OBJECT_ID('dbo.usp_RunFullLoad', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_RunFullLoad;
GO
CREATE PROCEDURE dbo.usp_RunFullLoad
AS
BEGIN
    SET NOCOUNT ON;
    PRINT '=== Full Load Procedure for PaymentsRiskAnalytics ===';
    PRINT 'This procedure documents the current working execution order. To actually run the ETL, execute the scripts in the following order:';
    PRINT '';
    PRINT '1. sql/01_create_database.sql';
    PRINT '2. sql/02_create_tables.sql';
    PRINT '3. sql/03_load_csvs.sql';
    PRINT '4. sql/04_load_dimensions_and_fact.sql';
    PRINT '5. sql/05_create_views.sql';
    PRINT '6. sql/06_validation_queries.sql';
    PRINT '7. sql/tests/10_data_quality_checks.sql';
    PRINT '8. sql/tests/11_reconciliation_tests.sql';
    PRINT '';
    PRINT 'Notes:';
    PRINT '- Before running, set the correct CSV path in sql/03_load_csvs.sql if the project folder moves.';
    PRINT '- Ensure the SQL Server instance is accessible and you have sufficient permissions.';
    PRINT '- After running the ETL, you can run the test scripts to verify data quality and reconciliation.';
    PRINT '';
    PRINT 'To run a script using sqlcmd:';
    PRINT '   sqlcmd -S <server_instance> -d PaymentsRiskAnalytics -i <script_path>.sql';
    PRINT 'Or in SSMS: open the script and press Execute.';
END;
GO

PRINT 'Stored procedure dbo.usp_RunFullLoad created.';
GO
