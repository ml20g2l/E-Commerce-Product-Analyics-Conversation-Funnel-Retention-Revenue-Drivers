/*
===========================================================
Project:
E-commerce Product Analytics

File:
08_product_performance.sql

Business Question:
Which brands, products, and price ranges drive purchases
and revenue performance?

Purpose:
Analyse product performance using reliable session-level
and revenue KPIs.

Business Value:
Support merchandising, product placement, pricing,
and promotion decisions using purchase behaviour and revenue.

Input:
clean_events

Outputs:
brand_performance
product_performance
price_band_performance

Author:
Geeyoon Lim
===========================================================
*/


/* 1. Brand performance */

DROP TABLE IF EXISTS brand_performance;

CREATE TABLE brand_performance AS
SELECT
    COALESCE(brand, 'Unknown') AS brand,

    COUNT(DISTINCT user_session) AS total_sessions,

    COUNT(DISTINCT user_session) FILTER (
        WHERE event_type = 'view'
    ) AS view_sessions,

    COUNT(DISTINCT user_session) FILTER (
        WHERE event_type = 'cart'
    ) AS cart_sessions,

    COUNT(DISTINCT user_session) FILTER (
        WHERE event_type = 'purchase'
    ) AS purchase_sessions,

    ROUND(
        COUNT(DISTINCT user_session) FILTER (WHERE event_type = 'purchase')::numeric
        / NULLIF(COUNT(DISTINCT user_session), 0),
        4
    ) AS purchase_session_rate,

    ROUND(
        SUM(price) FILTER (
            WHERE event_type = 'purchase'
              AND price > 0
        ),
        2
    ) AS total_revenue,

    ROUND(
        SUM(price) FILTER (
            WHERE event_type = 'purchase'
              AND price > 0
        )
        / NULLIF(
            COUNT(DISTINCT user_session) FILTER (WHERE event_type = 'purchase'),
            0
        ),
        2
    ) AS revenue_per_purchase_session

FROM clean_events
GROUP BY COALESCE(brand, 'Unknown')
HAVING COUNT(DISTINCT user_session) >= 1000
ORDER BY total_revenue DESC;


/* 2. Product performance */

DROP TABLE IF EXISTS product_performance;

CREATE TABLE product_performance AS
SELECT
    product_id,
    COALESCE(brand, 'Unknown') AS brand,
    COALESCE(category_code, 'Unknown') AS category_code,

    COUNT(DISTINCT user_session) AS total_sessions,

    COUNT(DISTINCT user_session) FILTER (
        WHERE event_type = 'view'
    ) AS view_sessions,

    COUNT(DISTINCT user_session) FILTER (
        WHERE event_type = 'cart'
    ) AS cart_sessions,

    COUNT(DISTINCT user_session) FILTER (
        WHERE event_type = 'purchase'
    ) AS purchase_sessions,

    ROUND(
        COUNT(DISTINCT user_session) FILTER (WHERE event_type = 'purchase')::numeric
        / NULLIF(COUNT(DISTINCT user_session), 0),
        4
    ) AS purchase_session_rate,

    ROUND(
        SUM(price) FILTER (
            WHERE event_type = 'purchase'
              AND price > 0
        ),
        2
    ) AS total_revenue,

    ROUND(
        SUM(price) FILTER (
            WHERE event_type = 'purchase'
              AND price > 0
        )
        / NULLIF(
            COUNT(DISTINCT user_session) FILTER (WHERE event_type = 'purchase'),
            0
        ),
        2
    ) AS revenue_per_purchase_session,

    RANK() OVER (
        ORDER BY SUM(price) FILTER (
            WHERE event_type = 'purchase'
              AND price > 0
        ) DESC
    ) AS revenue_rank,

    RANK() OVER (
        ORDER BY COUNT(DISTINCT user_session) FILTER (
            WHERE event_type = 'purchase'
        ) DESC
    ) AS purchase_rank

FROM clean_events
GROUP BY product_id, COALESCE(brand, 'Unknown'), COALESCE(category_code, 'Unknown')
HAVING COUNT(DISTINCT user_session) >= 500
ORDER BY total_revenue DESC;


/* 3. Price band performance */

DROP TABLE IF EXISTS price_band_performance;

CREATE TABLE price_band_performance AS
WITH event_price_bands AS (
    SELECT
        user_session,
        event_type,
        price,

        CASE
            WHEN price <= 0 THEN 'Invalid or free'
            WHEN price < 5 THEN 'Under £5'
            WHEN price >= 5 AND price < 10 THEN '£5-£9.99'
            WHEN price >= 10 AND price < 20 THEN '£10-£19.99'
            WHEN price >= 20 AND price < 50 THEN '£20-£49.99'
            ELSE '£50+'
        END AS price_band,

        CASE
            WHEN price <= 0 THEN 0
            WHEN price < 5 THEN 1
            WHEN price >= 5 AND price < 10 THEN 2
            WHEN price >= 10 AND price < 20 THEN 3
            WHEN price >= 20 AND price < 50 THEN 4
            ELSE 5
        END AS price_band_order

    FROM clean_events
    WHERE price IS NOT NULL
)

SELECT
    price_band,
    price_band_order,

    COUNT(DISTINCT user_session) AS total_sessions,

    COUNT(DISTINCT user_session) FILTER (
        WHERE event_type = 'view'
    ) AS view_sessions,

    COUNT(DISTINCT user_session) FILTER (
        WHERE event_type = 'cart'
    ) AS cart_sessions,

    COUNT(DISTINCT user_session) FILTER (
        WHERE event_type = 'purchase'
    ) AS purchase_sessions,

    ROUND(
        COUNT(DISTINCT user_session) FILTER (WHERE event_type = 'purchase')::numeric
        / NULLIF(COUNT(DISTINCT user_session), 0),
        4
    ) AS purchase_session_rate,

    ROUND(
        SUM(price) FILTER (
            WHERE event_type = 'purchase'
              AND price > 0
        ),
        2
    ) AS total_revenue,

    ROUND(
        SUM(price) FILTER (
            WHERE event_type = 'purchase'
              AND price > 0
        )
        / NULLIF(
            COUNT(DISTINCT user_session) FILTER (WHERE event_type = 'purchase'),
            0
        ),
        2
    ) AS revenue_per_purchase_session

FROM event_price_bands
GROUP BY price_band, price_band_order
ORDER BY price_band_order;

/* 4. Session duration conversion analysis */
DROP TABLE IF EXISTS session_duration_conversion;

CREATE TABLE session_duration_conversion AS
SELECT
    CASE
        WHEN session_duration_minutes < 1 THEN '<1 min'
        WHEN session_duration_minutes < 3 THEN '1-3 min'
        WHEN session_duration_minutes < 5 THEN '3-5 min'
        WHEN session_duration_minutes < 10 THEN '5-10 min'
        ELSE '10+ min'
    END AS duration_bucket,

    CASE
        WHEN session_duration_minutes < 1 THEN 1
        WHEN session_duration_minutes < 3 THEN 2
        WHEN session_duration_minutes < 5 THEN 3
        WHEN session_duration_minutes < 10 THEN 4
        ELSE 5
    END AS duration_order,

    COUNT(*) AS sessions,
    SUM(converted_flag) AS converted_sessions,

    ROUND(
        SUM(converted_flag)::numeric / COUNT(*),
        4
    ) AS conversion_rate

FROM session_journey
GROUP BY
    duration_bucket,
    duration_order
ORDER BY duration_order;
