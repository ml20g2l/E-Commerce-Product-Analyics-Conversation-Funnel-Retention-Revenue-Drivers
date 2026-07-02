-- ======================================================
-- 14_price_opportunity_analysis.sql
-- Phase 2
-- Price Opportunity Discovery
-- ======================================================

DROP TABLE IF EXISTS price_band_opportunities;

CREATE TABLE price_band_opportunities AS

SELECT
    price_band,
    price_band_order,

    total_sessions,
    view_sessions,
    cart_sessions,
    purchase_sessions,

    view_to_cart_rate,
    cart_to_purchase_rate,
    overall_conversion_rate,

    total_revenue,
    revenue_per_purchase_session,

    cart_sessions - purchase_sessions AS abandoned_cart_sessions,

    ROUND(
        (cart_sessions - purchase_sessions)::numeric
        / NULLIF(cart_sessions,0),
        4
    ) AS cart_abandonment_rate

FROM price_band_conversion_drivers

WHERE price_band <> 'Invalid or free'

ORDER BY price_band_order;


/* Step 2. Revenue Opportunity Ranking
   Identify price bands with strong revenue but weak conversion performance.
*/

SELECT

    price_band,

    total_revenue,

    revenue_per_purchase_session,

    overall_conversion_rate,

    view_to_cart_rate,

    cart_to_purchase_rate,

    cart_abandonment_rate

FROM price_band_opportunities

ORDER BY revenue_per_purchase_session DESC;

/* Step 3. Stage Diagnosis
   Identify price bands with strong revenue but weak conversion performance.
*/

SELECT

    price_band,

    CASE

        WHEN view_to_cart_rate < 0.15
             THEN 'Early funnel friction'

        WHEN cart_to_purchase_rate < 0.20
             THEN 'Checkout friction'

        ELSE 'Healthy funnel'

    END AS primary_problem,

    view_to_cart_rate,

    cart_to_purchase_rate,

    overall_conversion_rate,

    revenue_per_purchase_session,

    total_revenue

FROM price_band_opportunities

ORDER BY price_band_order;


/* Stage 4. Experiment Recommendation Table
   Identify price bands with strong revenue but weak conversion performance.
*/

SELECT

    price_band,

    primary_problem,

    CASE

        WHEN primary_problem = 'Early funnel friction'

        THEN 'Test value reassurance, delivery messaging, payment flexibility or product trust signals.'

        WHEN primary_problem = 'Checkout friction'

        THEN 'Test free shipping, checkout simplification or abandoned-cart reminders.'

        ELSE 'Monitor performance.'

    END AS proposed_experiment

FROM (

    SELECT

        price_band,

        CASE

            WHEN view_to_cart_rate < 0.15
                 THEN 'Early funnel friction'

            WHEN cart_to_purchase_rate < 0.20
                 THEN 'Checkout friction'

            ELSE 'Healthy funnel'

        END AS primary_problem

    FROM price_band_opportunities

) t;