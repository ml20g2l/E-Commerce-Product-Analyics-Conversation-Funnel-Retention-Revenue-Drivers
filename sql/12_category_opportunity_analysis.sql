-- 12_category_opportunity_analysis.sql
-- Phase 2: Opportunity Discovery
-- Goal: identify categories with high customer intent but weak purchase completion.

DROP TABLE IF EXISTS category_conversion_opportunities;

CREATE TABLE category_conversion_opportunities AS
SELECT
    category_code,
    COUNT(DISTINCT product_id) AS products,
    SUM(total_sessions) AS total_sessions,
    SUM(view_sessions) AS view_sessions,
    SUM(cart_sessions) AS cart_sessions,
    SUM(purchase_sessions) AS purchase_sessions,

    ROUND(SUM(cart_sessions)::numeric / NULLIF(SUM(view_sessions), 0), 4) AS view_to_cart_rate,
    ROUND(SUM(purchase_sessions)::numeric / NULLIF(SUM(cart_sessions), 0), 4) AS cart_to_purchase_rate,
    ROUND(SUM(purchase_sessions)::numeric / NULLIF(SUM(view_sessions), 0), 4) AS overall_conversion_rate,

    SUM(total_revenue) AS total_revenue,
    ROUND(SUM(total_revenue)::numeric / NULLIF(SUM(purchase_sessions), 0), 2) AS revenue_per_purchase_session,

    SUM(cart_sessions) - SUM(purchase_sessions) AS abandoned_cart_sessions,
    ROUND(
        (SUM(cart_sessions) - SUM(purchase_sessions))::numeric
        / NULLIF(SUM(cart_sessions), 0),
        4
    ) AS cart_abandonment_rate
FROM product_conversion_drivers
WHERE category_code IS NOT NULL
  AND category_code <> 'Unknown'
GROUP BY category_code
HAVING SUM(view_sessions) >= 1000
ORDER BY abandoned_cart_sessions DESC;


-- Check the largest abandoned-cart opportunities
SELECT *
FROM category_conversion_opportunities
ORDER BY abandoned_cart_sessions DESC
LIMIT 20;


-- Check categories with high views but weak add-to-cart behaviour
SELECT *
FROM category_conversion_opportunities
WHERE view_sessions >= 10000
ORDER BY view_to_cart_rate ASC
LIMIT 20;


-- Check categories with strong revenue but weaker conversion
SELECT *
FROM category_conversion_opportunities
WHERE total_revenue IS NOT NULL
ORDER BY total_revenue DESC
LIMIT 20;