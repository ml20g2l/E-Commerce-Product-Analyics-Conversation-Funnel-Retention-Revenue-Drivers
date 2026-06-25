/*
===========================================================
Project:
E-commerce Product Analytics

File:
07_behaviour_conversion_analysis.sql

Business Question:
Which customer behaviours are associated with higher purchase conversion?

Purpose:
Analyse conversion rates by behavioural intensity,
including product views, cart additions, remove-from-cart
activity, and product exploration.

Business Value:
Help identify customer behaviours that signal purchase intent
and support product recommendations for improving conversion.

Input:
session_journey

Outputs:
behaviour_conversion_summary

Author:
Geeyoon Lim
===========================================================
*/


DROP TABLE IF EXISTS behaviour_conversion_summary;

CREATE TABLE behaviour_conversion_summary AS
WITH behaviour_buckets AS (
    SELECT
        user_session,
        user_id,
        converted_flag,

        CASE
            WHEN view_count = 0 THEN '0 views'
            WHEN view_count = 1 THEN '1 view'
            WHEN view_count BETWEEN 2 AND 5 THEN '2-5 views'
            WHEN view_count BETWEEN 6 AND 10 THEN '6-10 views'
            ELSE '11+ views'
        END AS view_bucket,

        CASE
            WHEN cart_count = 0 THEN '0 carts'
            WHEN cart_count = 1 THEN '1 cart'
            WHEN cart_count BETWEEN 2 AND 5 THEN '2-5 carts'
            WHEN cart_count BETWEEN 6 AND 10 THEN '6-10 carts'
            ELSE '11+ carts'
        END AS cart_bucket,

        CASE
            WHEN remove_from_cart_count = 0 THEN '0 removes'
            WHEN remove_from_cart_count = 1 THEN '1 remove'
            WHEN remove_from_cart_count BETWEEN 2 AND 5 THEN '2-5 removes'
            WHEN remove_from_cart_count BETWEEN 6 AND 10 THEN '6-10 removes'
            ELSE '11+ removes'
        END AS remove_bucket,

        CASE
            WHEN unique_products_viewed = 0 THEN '0 products viewed'
            WHEN unique_products_viewed = 1 THEN '1 product viewed'
            WHEN unique_products_viewed BETWEEN 2 AND 5 THEN '2-5 products viewed'
            WHEN unique_products_viewed BETWEEN 6 AND 10 THEN '6-10 products viewed'
            ELSE '11+ products viewed'
        END AS product_exploration_bucket

    FROM session_journey
)

SELECT
    'View Count' AS behaviour_type,
    view_bucket AS behaviour_bucket,
    COUNT(*) AS sessions,
    SUM(converted_flag) AS converted_sessions,
    ROUND(SUM(converted_flag)::numeric / NULLIF(COUNT(*), 0), 4) AS conversion_rate
FROM behaviour_buckets
GROUP BY view_bucket

UNION ALL

SELECT
    'Cart Count' AS behaviour_type,
    cart_bucket AS behaviour_bucket,
    COUNT(*) AS sessions,
    SUM(converted_flag) AS converted_sessions,
    ROUND(SUM(converted_flag)::numeric / NULLIF(COUNT(*), 0), 4) AS conversion_rate
FROM behaviour_buckets
GROUP BY cart_bucket

UNION ALL

SELECT
    'Remove from Cart Count' AS behaviour_type,
    remove_bucket AS behaviour_bucket,
    COUNT(*) AS sessions,
    SUM(converted_flag) AS converted_sessions,
    ROUND(SUM(converted_flag)::numeric / NULLIF(COUNT(*), 0), 4) AS conversion_rate
FROM behaviour_buckets
GROUP BY remove_bucket

UNION ALL

SELECT
    'Product Exploration' AS behaviour_type,
    product_exploration_bucket AS behaviour_bucket,
    COUNT(*) AS sessions,
    SUM(converted_flag) AS converted_sessions,
    ROUND(SUM(converted_flag)::numeric / NULLIF(COUNT(*), 0), 4) AS conversion_rate
FROM behaviour_buckets
GROUP BY product_exploration_bucket;