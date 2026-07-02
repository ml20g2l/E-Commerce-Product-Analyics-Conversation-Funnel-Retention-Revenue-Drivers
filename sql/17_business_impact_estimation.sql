-- ======================================================
-- 17_business_impact_estimation.sql
-- Phase 2: Business Impact Estimation
-- Goal: estimate potential incremental purchases and revenue from proposed experiments.
-- ======================================================

DROP TABLE IF EXISTS experiment_impact_estimation;

CREATE TABLE experiment_impact_estimation (
    priority text,
    opportunity_area text,
    target_segment text,
    baseline_sessions numeric,
    baseline_conversion_rate numeric,
    baseline_purchases numeric,
    revenue_per_purchase numeric,
    uplift_low numeric,
    uplift_high numeric
);


INSERT INTO experiment_impact_estimation
VALUES
(
    'P1',
    'High-intent lost sessions',
    'Users who added 3-20 items to cart but did not purchase',
    310249,
    0.1241,
    310249 * 0.1241,
    40.57,
    0.03,
    0.05
),
(
    'P2',
    'High exploration lost sessions',
    'Users who viewed 7+ products but did not purchase',
    147445,
    0.1385,
    147445 * 0.1385,
    40.57,
    0.02,
    0.04
),
(
    'P3',
    'Vacuum category cart abandonment',
    'appliances.environment.vacuum',
    12410,
    0.2575,
    3195,
    39.88,
    0.03,
    0.05
),
(
    'P4',
    'High-price product friction',
    '£50+ products',
    324937,
    0.0782,
    25411,
    101.76,
    0.02,
    0.04
),
(
    'P5',
    'Under £5 checkout friction',
    'Under £5 products',
    696183,
    0.1793,
    124803,
    16.77,
    0.02,
    0.04
);


-- Final impact estimate
SELECT
    priority,
    opportunity_area,
    target_segment,
    baseline_sessions,
    baseline_conversion_rate,
    ROUND(baseline_purchases, 0) AS baseline_purchases,
    revenue_per_purchase,

    uplift_low,
    uplift_high,

    ROUND(baseline_purchases * uplift_low, 0) AS incremental_purchases_low,
    ROUND(baseline_purchases * uplift_high, 0) AS incremental_purchases_high,

    ROUND((baseline_purchases * uplift_low * revenue_per_purchase)::numeric, 2) AS incremental_revenue_low,
    ROUND((baseline_purchases * uplift_high * revenue_per_purchase)::numeric, 2) AS incremental_revenue_high

FROM experiment_impact_estimation
ORDER BY priority;