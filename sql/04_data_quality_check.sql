/*
===========================================================
Project:
E-commerce Product Analytics

File:
04_data_quality_check.sql

Purpose:
Validate the cleaned event data before building funnel,
retention, customer, and revenue analysis tables.

Business Value:
Ensure that dashboard metrics and recommendations are based
on complete, consistent, and reliable event data.

Author:
Geeyoon Lim
===========================================================
*/

-- 1. Overall data coverage
SELECT
    MIN(event_time) AS start_date,
    MAX(event_time) AS end_date,
    COUNT(*) AS total_events,
    COUNT(DISTINCT user_id) AS total_users,
    COUNT(DISTINCT user_session) AS total_sessions
FROM clean_events;


-- 2. Event type distribution
SELECT
    event_type,
    COUNT(*) AS event_count,
    ROUND(
        COUNT(*)::numeric / SUM(COUNT(*)) OVER (),
        4
    ) AS event_share
FROM clean_events
GROUP BY event_type
ORDER BY event_count DESC;


-- 3. Monthly event volume
SELECT
    event_month,
    COUNT(*) AS total_events,
    COUNT(DISTINCT user_id) AS unique_users,
    COUNT(DISTINCT user_session) AS unique_sessions
FROM clean_events
GROUP BY event_month
ORDER BY event_month;


-- 4. Missing values check
SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (WHERE product_id IS NULL) AS missing_product_id,
    COUNT(*) FILTER (WHERE category_id IS NULL) AS missing_category_id,
    COUNT(*) FILTER (WHERE category_code IS NULL) AS missing_category_code,
    COUNT(*) FILTER (WHERE brand IS NULL) AS missing_brand,
    COUNT(*) FILTER (WHERE price IS NULL) AS missing_price,
    COUNT(*) FILTER (WHERE user_id IS NULL) AS missing_user_id,
    COUNT(*) FILTER (WHERE user_session IS NULL) AS missing_user_session

FROM clean_events;


-- 5. Price validation
SELECT
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    ROUND(AVG(price), 2) AS avg_price,
    COUNT(*) FILTER (WHERE price < 0) AS negative_price_rows,
    COUNT(*) FILTER (WHERE price = 0) AS zero_price_rows
FROM clean_events;


-- 6. Purchase revenue check: all purchase events
SELECT
    COUNT(*) AS purchase_events,
    ROUND(SUM(price), 2) AS total_revenue,
    ROUND(AVG(price), 2) AS average_purchase_value,
    ROUND(MIN(price), 2) AS min_purchase_value,
    ROUND(MAX(price), 2) AS max_purchase_value
FROM clean_events
WHERE event_type = 'purchase';


-- 7. Purchase revenue check: valid positive-price purchases only
SELECT
    COUNT(*) AS valid_purchase_events,
    ROUND(SUM(price), 2) AS valid_total_revenue,
    ROUND(AVG(price), 2) AS valid_average_purchase_value,
    ROUND(MIN(price), 2) AS valid_min_purchase_value,
    ROUND(MAX(price), 2) AS valid_max_purchase_value
FROM clean_events
WHERE event_type = 'purchase'
  AND price > 0;


-- 8. Price issue share
SELECT
    COUNT(*) AS total_events,
    COUNT(*) FILTER (WHERE price < 0) AS negative_price_rows,
    COUNT(*) FILTER (WHERE price = 0) AS zero_price_rows,
    ROUND(
        COUNT(*) FILTER (WHERE price < 0)::numeric / COUNT(*),
        6
    ) AS negative_price_share,
    ROUND(
        COUNT(*) FILTER (WHERE price = 0)::numeric / COUNT(*),
        6
    ) AS zero_price_share
FROM clean_events;

  /*
Data Quality Decision:
- Negative price rows were identified in the dataset.
- Zero price rows were also identified.
- clean_events keeps all valid user/session events for behavioural analysis.
- Revenue-related analysis will use only positive-price purchase events:
  event_type = 'purchase' AND price > 0.
*/