-- Imported 5 monthly CSV files into raw_events using pgAdmin Import/Export.
-- Source dataset: Kaggle - eCommerce Events History in Cosmetics Shop
-- Files imported:
-- 2019-Oct.csv
-- 2019-Nov.csv
-- 2019-Dec.csv
-- 2020-Jan.csv
-- 2020-Feb.csv

-- Validation checks after import:
SELECT COUNT(*)
FROM raw_events;

SELECT *
FROM raw_events
LIMIT 10;

SELECT 
    event_type,
    COUNT(*) AS event_count
FROM raw_events
GROUP BY event_type
ORDER BY event_count DESC;