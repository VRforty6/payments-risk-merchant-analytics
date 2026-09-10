IF DB_ID(N'PaymentsRiskAnalytics') IS NULL
BEGIN
    CREATE DATABASE PaymentsRiskAnalytics;
    PRINT 'Database PaymentsRiskAnalytics created.';
END
ELSE
BEGIN
    PRINT 'Database PaymentsRiskAnalytics already exists.';
END
GO