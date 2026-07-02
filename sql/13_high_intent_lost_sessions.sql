-- ======================================================
-- 13_high_intent_lost_sessions.sql
-- Phase 2: High-intent Lost Sessions
-- Goal: identify users who showed strong purchase intent but left without purchasing.
-- ======================================================


-- 1. Overall session opportunity size
SELECT
    COUNT(*) AS total_sessions,

    SUM(
        CASE
            WHEN converted_flag = 0 THEN 1
            ELSE 0
        END
    ) AS non_converted_sessions,

    SUM(
        CASE
            WHEN cart_abandoned_flag = 1 THEN 1
            ELSE 0
        END
    ) AS abandoned_cart_sessions,

    SUM(
        CASE
            WHEN cart_count >= 1
                 AND converted_flag = 0 THEN 1
            ELSE 0
        END
    ) AS carted_but_not_purchased_sessions
FROM session_journey;


-- 2. Conversion rate by cart-count bucket
WITH cart_bucket_summary AS (
    SELECT
        CASE
            WHEN cart_count = 0 THEN '0'
            WHEN cart_count = 1 THEN '1'
            WHEN cart_count = 2 THEN '2'
            WHEN cart_count BETWEEN 3 AND 5 THEN '3-5'
            ELSE '6+'
        END AS cart_bucket,

        CASE
            WHEN cart_count = 0 THEN 1
            WHEN cart_count = 1 THEN 2
            WHEN cart_count = 2 THEN 3
            WHEN cart_count BETWEEN 3 AND 5 THEN 4
            ELSE 5
        END AS cart_bucket_order,

        COUNT(*) AS sessions,
        SUM(converted_flag) AS purchases,
        ROUND(AVG(converted_flag)::numeric, 4) AS conversion_rate
    FROM session_journey
    GROUP BY 1, 2
)
SELECT
    cart_bucket,
    sessions,
    purchases,
    conversion_rate
FROM cart_bucket_summary
ORDER BY cart_bucket_order;


-- 3. Raw high-intent lost sessions
SELECT
    COUNT(*) AS raw_lost_high_intent_sessions,
    ROUND(AVG(cart_count)::numeric, 2) AS avg_cart_items,
    ROUND(AVG(view_count)::numeric, 2) AS avg_views,
    ROUND(AVG(unique_products_interacted)::numeric, 2) AS avg_products,
    ROUND(AVG(session_duration_minutes)::numeric, 2) AS avg_session_duration
FROM session_journey
WHERE cart_count >= 3
  AND converted_flag = 0;


-- 4. Cleaned high-intent lost sessions
-- Filters remove extreme session outliers to make the segment more realistic for product experimentation.
DROP TABLE IF EXISTS high_intent_lost_sessions;

CREATE TABLE high_intent_lost_sessions AS
SELECT
    user_session,
    user_id,
    session_start_time,
    session_end_time,
    session_duration_minutes,
    total_events,
    view_count,
    cart_count,
    remove_from_cart_count,
    unique_products_interacted,
    unique_products_viewed,
    unique_products_added_to_cart,
    cart_abandoned_flag
FROM session_journey
WHERE converted_flag = 0
  AND cart_count BETWEEN 3 AND 20
  AND session_duration_minutes BETWEEN 1 AND 180;


-- 5. Cleaned high-intent lost session summary
SELECT
    COUNT(*) AS cleaned_lost_high_intent_sessions,
    ROUND(AVG(cart_count)::numeric, 2) AS avg_cart_items,
    ROUND(AVG(view_count)::numeric, 2) AS avg_views,
    ROUND(AVG(unique_products_interacted)::numeric, 2) AS avg_products,
    ROUND(AVG(session_duration_minutes)::numeric, 2) AS avg_session_duration
FROM high_intent_lost_sessions;


-- 6. Sample of cleaned high-intent lost sessions
SELECT *
FROM high_intent_lost_sessions
ORDER BY cart_count DESC, session_duration_minutes DESC
LIMIT 20;