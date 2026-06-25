/*
===========================================================
Project:
E-commerce Product Analytics

File:
06_session_journey.sql

Business Question:
Which customer behaviours are associated with purchase conversion?

Purpose:
Create a session-level customer journey table to compare
converted and non-converted sessions.

Business Value:
Identify behavioural patterns such as product views,
cart additions, removals, session duration, and revenue
that may explain purchase conversion or drop-off.

Output:
session_journey

Author:
Geeyoon Lim
===========================================================
*/


DROP TABLE IF EXISTS session_journey;

CREATE TABLE session_journey AS
SELECT
    user_session,
    user_id,

    MIN(event_time) AS session_start_time,
    MAX(event_time) AS session_end_time,

    EXTRACT(EPOCH FROM MAX(event_time) - MIN(event_time)) / 60
        AS session_duration_minutes,

    COUNT(*) AS total_events,

    COUNT(*) FILTER (WHERE event_type = 'view') AS view_count,
    COUNT(*) FILTER (WHERE event_type = 'cart') AS cart_count,
    COUNT(*) FILTER (WHERE event_type = 'remove_from_cart') AS remove_from_cart_count,
    COUNT(*) FILTER (WHERE event_type = 'purchase') AS purchase_count,

    COUNT(DISTINCT product_id) AS unique_products_interacted,
    COUNT(DISTINCT product_id) FILTER (WHERE event_type = 'view') AS unique_products_viewed,
    COUNT(DISTINCT product_id) FILTER (WHERE event_type = 'cart') AS unique_products_added_to_cart,
    COUNT(DISTINCT product_id) FILTER (WHERE event_type = 'purchase') AS unique_products_purchased,

    SUM(price) FILTER (
        WHERE event_type = 'purchase'
          AND price > 0
    ) AS session_revenue,

    CASE
        WHEN COUNT(*) FILTER (WHERE event_type = 'purchase') > 0
        THEN 1 ELSE 0
    END AS converted_flag,

    CASE
        WHEN COUNT(*) FILTER (WHERE event_type = 'cart') > 0
         AND COUNT(*) FILTER (WHERE event_type = 'purchase') = 0
        THEN 1 ELSE 0
    END AS cart_abandoned_flag,

    CASE
        WHEN COUNT(*) FILTER (WHERE event_type = 'remove_from_cart') > 0
        THEN 1 ELSE 0
    END AS had_remove_from_cart_flag

FROM clean_events
GROUP BY user_session, user_id;