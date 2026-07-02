-- ======================================================
-- 15_product_engagement_opportunity.sql
-- Phase 2: Product Engagement Opportunity
-- Goal: understand whether product exploration is linked to purchase conversion.
-- ======================================================


-- 1. Conversion by number of unique products viewed
DROP TABLE IF EXISTS product_engagement_opportunities;

CREATE TABLE product_engagement_opportunities AS
WITH engagement_buckets AS (
    SELECT
        CASE
            WHEN unique_products_viewed = 0 THEN '0'
            WHEN unique_products_viewed = 1 THEN '1'
            WHEN unique_products_viewed BETWEEN 2 AND 3 THEN '2-3'
            WHEN unique_products_viewed BETWEEN 4 AND 6 THEN '4-6'
            WHEN unique_products_viewed BETWEEN 7 AND 10 THEN '7-10'
            ELSE '11+'
        END AS product_view_bucket,

        CASE
            WHEN unique_products_viewed = 0 THEN 0
            WHEN unique_products_viewed = 1 THEN 1
            WHEN unique_products_viewed BETWEEN 2 AND 3 THEN 2
            WHEN unique_products_viewed BETWEEN 4 AND 6 THEN 3
            WHEN unique_products_viewed BETWEEN 7 AND 10 THEN 4
            ELSE 5
        END AS bucket_order,

        COUNT(*) AS sessions,
        SUM(converted_flag) AS converted_sessions,
        ROUND(AVG(converted_flag)::numeric, 4) AS conversion_rate,
        ROUND(AVG(cart_count)::numeric, 2) AS avg_cart_count,
        ROUND(AVG(session_duration_minutes)::numeric, 2) AS avg_session_duration
    FROM session_journey
    WHERE session_duration_minutes BETWEEN 0 AND 180
    GROUP BY 1, 2
)
SELECT *
FROM engagement_buckets
ORDER BY bucket_order;


-- 2. Check product exploration conversion pattern
SELECT
    product_view_bucket,
    sessions,
    converted_sessions,
    conversion_rate,
    avg_cart_count,
    avg_session_duration
FROM product_engagement_opportunities
ORDER BY bucket_order;


-- 3. Identify low-exploration sessions
SELECT
    COUNT(*) AS low_exploration_sessions,
    SUM(converted_flag) AS converted_sessions,
    ROUND(AVG(converted_flag)::numeric, 4) AS conversion_rate,
    ROUND(AVG(cart_count)::numeric, 2) AS avg_cart_count,
    ROUND(AVG(session_duration_minutes)::numeric, 2) AS avg_session_duration
FROM session_journey
WHERE unique_products_viewed BETWEEN 1 AND 3
  AND session_duration_minutes BETWEEN 0 AND 180;


-- 4. Identify high-exploration non-converted sessions
DROP TABLE IF EXISTS high_exploration_lost_sessions;

CREATE TABLE high_exploration_lost_sessions AS
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
WHERE unique_products_viewed >= 7
  AND converted_flag = 0
  AND session_duration_minutes BETWEEN 1 AND 180;


-- 5. Summary of high-exploration lost sessions
SELECT
    COUNT(*) AS high_exploration_lost_sessions,
    ROUND(AVG(unique_products_viewed)::numeric, 2) AS avg_products_viewed,
    ROUND(AVG(cart_count)::numeric, 2) AS avg_cart_count,
    ROUND(AVG(session_duration_minutes)::numeric, 2) AS avg_session_duration
FROM high_exploration_lost_sessions;


-- 6. Sample high-exploration lost sessions
SELECT *
FROM high_exploration_lost_sessions
ORDER BY unique_products_viewed DESC, session_duration_minutes DESC
LIMIT 20;