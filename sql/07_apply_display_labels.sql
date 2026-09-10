-- 07_apply_display_labels.sql
-- Idempotently add and populate portfolio-facing display labels.
USE PaymentsRiskAnalytics;
GO

IF COL_LENGTH('staging.Merchants', 'merchant_display_name') IS NULL
    ALTER TABLE staging.Merchants ADD merchant_display_name VARCHAR(120) NULL;
GO

IF COL_LENGTH('staging.Countries', 'market_display_name') IS NULL
    ALTER TABLE staging.Countries ADD market_display_name VARCHAR(100) NULL;
GO

IF COL_LENGTH('dw.DimMerchant', 'MerchantDisplayName') IS NULL
    ALTER TABLE dw.DimMerchant ADD MerchantDisplayName VARCHAR(120) NULL;
GO

IF COL_LENGTH('dw.DimGeography', 'MarketDisplayName') IS NULL
    ALTER TABLE dw.DimGeography ADD MarketDisplayName VARCHAR(100) NULL;
GO

UPDATE m
SET merchant_display_name =
    CASE
        WHEN m.merchant_id = 'UNKNOWN' THEN 'Unknown Merchant'
        ELSE CONCAT(
            CASE merchant_num.MerchantNumber % 12
                WHEN 0 THEN 'Aster'
                WHEN 1 THEN 'Beacon'
                WHEN 2 THEN 'Cedar'
                WHEN 3 THEN 'Ember'
                WHEN 4 THEN 'Harbor'
                WHEN 5 THEN 'Keystone'
                WHEN 6 THEN 'Lumen'
                WHEN 7 THEN 'Meridian'
                WHEN 8 THEN 'Northstar'
                WHEN 9 THEN 'Prairie'
                WHEN 10 THEN 'Summit'
                ELSE 'Veridian'
            END,
            ' ',
            CASE LOWER(m.category)
                WHEN 'retail' THEN CASE merchant_num.MerchantNumber % 4 WHEN 0 THEN 'Goods' WHEN 1 THEN 'Supply' WHEN 2 THEN 'Market' ELSE 'Trading' END
                WHEN 'restaurant' THEN CASE merchant_num.MerchantNumber % 4 WHEN 0 THEN 'Table' WHEN 1 THEN 'Kitchen' WHEN 2 THEN 'Bistro' ELSE 'Pantry' END
                WHEN 'travel' THEN CASE merchant_num.MerchantNumber % 4 WHEN 0 THEN 'Voyages' WHEN 1 THEN 'Routes' WHEN 2 THEN 'Journey' ELSE 'Transit' END
                WHEN 'electronics' THEN CASE merchant_num.MerchantNumber % 4 WHEN 0 THEN 'Devices' WHEN 1 THEN 'Circuit' WHEN 2 THEN 'Signal' ELSE 'Systems' END
                WHEN 'clothing' THEN CASE merchant_num.MerchantNumber % 4 WHEN 0 THEN 'Apparel' WHEN 1 THEN 'Textiles' WHEN 2 THEN 'Threads' ELSE 'Wardrobe' END
                WHEN 'groceries' THEN CASE merchant_num.MerchantNumber % 4 WHEN 0 THEN 'Provisions' WHEN 1 THEN 'Harvest' WHEN 2 THEN 'Basket' ELSE 'Fresh' END
                WHEN 'healthcare' THEN CASE merchant_num.MerchantNumber % 4 WHEN 0 THEN 'Care' WHEN 1 THEN 'Wellness' WHEN 2 THEN 'Clinic' ELSE 'Health' END
                WHEN 'entertainment' THEN CASE merchant_num.MerchantNumber % 4 WHEN 0 THEN 'Events' WHEN 1 THEN 'Stage' WHEN 2 THEN 'Media' ELSE 'Leisure' END
                ELSE 'Commerce'
            END,
            ' ',
            RIGHT('000' + CAST(merchant_num.MerchantNumber AS varchar(10)), 3)
        )
    END
FROM staging.Merchants m
CROSS APPLY (
    SELECT COALESCE(TRY_CONVERT(int, REPLACE(m.merchant_id, 'M', '')), 0) AS MerchantNumber
) merchant_num;
GO

UPDATE c
SET market_display_name =
    CASE
        WHEN c.country_id = 'UNKNOWN' THEN 'Unknown Market'
        ELSE CONCAT(c.region, ' Market ', RIGHT('00' + CAST(COALESCE(TRY_CONVERT(int, REPLACE(c.country_id, 'CO', '')), 0) AS varchar(10)), 2))
    END
FROM staging.Countries c;
GO

UPDATE dm
SET MerchantDisplayName =
    CASE
        WHEN dm.MerchantID = 'UNKNOWN' THEN 'Unknown Merchant'
        ELSE COALESCE(
            NULLIF(sm.merchant_display_name, ''),
            CONCAT(
                CASE merchant_num.MerchantNumber % 12
                    WHEN 0 THEN 'Aster'
                    WHEN 1 THEN 'Beacon'
                    WHEN 2 THEN 'Cedar'
                    WHEN 3 THEN 'Ember'
                    WHEN 4 THEN 'Harbor'
                    WHEN 5 THEN 'Keystone'
                    WHEN 6 THEN 'Lumen'
                    WHEN 7 THEN 'Meridian'
                    WHEN 8 THEN 'Northstar'
                    WHEN 9 THEN 'Prairie'
                    WHEN 10 THEN 'Summit'
                    ELSE 'Veridian'
                END,
                ' ',
                CASE LOWER(dm.Category)
                    WHEN 'retail' THEN CASE merchant_num.MerchantNumber % 4 WHEN 0 THEN 'Goods' WHEN 1 THEN 'Supply' WHEN 2 THEN 'Market' ELSE 'Trading' END
                    WHEN 'restaurant' THEN CASE merchant_num.MerchantNumber % 4 WHEN 0 THEN 'Table' WHEN 1 THEN 'Kitchen' WHEN 2 THEN 'Bistro' ELSE 'Pantry' END
                    WHEN 'travel' THEN CASE merchant_num.MerchantNumber % 4 WHEN 0 THEN 'Voyages' WHEN 1 THEN 'Routes' WHEN 2 THEN 'Journey' ELSE 'Transit' END
                    WHEN 'electronics' THEN CASE merchant_num.MerchantNumber % 4 WHEN 0 THEN 'Devices' WHEN 1 THEN 'Circuit' WHEN 2 THEN 'Signal' ELSE 'Systems' END
                    WHEN 'clothing' THEN CASE merchant_num.MerchantNumber % 4 WHEN 0 THEN 'Apparel' WHEN 1 THEN 'Textiles' WHEN 2 THEN 'Threads' ELSE 'Wardrobe' END
                    WHEN 'groceries' THEN CASE merchant_num.MerchantNumber % 4 WHEN 0 THEN 'Provisions' WHEN 1 THEN 'Harvest' WHEN 2 THEN 'Basket' ELSE 'Fresh' END
                    WHEN 'healthcare' THEN CASE merchant_num.MerchantNumber % 4 WHEN 0 THEN 'Care' WHEN 1 THEN 'Wellness' WHEN 2 THEN 'Clinic' ELSE 'Health' END
                    WHEN 'entertainment' THEN CASE merchant_num.MerchantNumber % 4 WHEN 0 THEN 'Events' WHEN 1 THEN 'Stage' WHEN 2 THEN 'Media' ELSE 'Leisure' END
                    ELSE 'Commerce'
                END,
                ' ',
                RIGHT('000' + CAST(merchant_num.MerchantNumber AS varchar(10)), 3)
            )
        )
    END
FROM dw.DimMerchant dm
LEFT JOIN staging.Merchants sm
    ON sm.merchant_id = dm.MerchantID
CROSS APPLY (
    SELECT COALESCE(TRY_CONVERT(int, REPLACE(dm.MerchantID, 'M', '')), 0) AS MerchantNumber
) merchant_num;
GO

UPDATE dg
SET MarketDisplayName =
    CASE
        WHEN dg.CountryID = 'UNKNOWN' THEN 'Unknown Market'
        ELSE COALESCE(
            NULLIF(sc.market_display_name, ''),
            CONCAT(dg.Region, ' Market ', RIGHT('00' + CAST(COALESCE(TRY_CONVERT(int, REPLACE(dg.CountryID, 'CO', '')), 0) AS varchar(10)), 2))
        )
    END
FROM dw.DimGeography dg
LEFT JOIN staging.Countries sc
    ON sc.country_id = dg.CountryID;
GO

SELECT 'DimMerchant Missing MerchantDisplayName' AS CheckName, COUNT(*) AS IssueCount
FROM dw.DimMerchant
WHERE NULLIF(MerchantDisplayName, '') IS NULL
UNION ALL
SELECT 'DimGeography Missing MarketDisplayName', COUNT(*)
FROM dw.DimGeography
WHERE NULLIF(MarketDisplayName, '') IS NULL;
GO
