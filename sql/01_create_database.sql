-- 01_create_database.sql
-- Create database PaymentsRiskAnalytics if not exists
IF DB_ID(N'PaymentsRiskAnalytics') IS NULL
BEGIN
    CREATE DATABASE PaymentsRiskAnalytics;
END
GO

USE PaymentsRiskAnalytics;
GO