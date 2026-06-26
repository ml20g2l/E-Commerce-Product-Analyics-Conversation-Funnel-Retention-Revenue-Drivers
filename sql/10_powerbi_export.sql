/*
===========================================================
Project:
E-commerce Product Analytics

File:
10_powerbi_export.sql

Purpose:
Validate reporting tables before importing into Power BI.

Business Value:
Ensure all reporting tables are analysis-ready and contain
no duplicate records or unexpected null values.

Reporting Tables:
- monthly_conversion_funnel
- session_journey
- brand_performance
- product_performance
- price_band_performance
- cohort_retention

Author:
Geeyoon Lim
===========================================================
*/


/* =======================================================
1. monthly_conversion_funnel
======================================================= */

SELECT COUNT(*) AS total_rows
FROM monthly_conversion_funnel;

SELECT *
FROM monthly_conversion_funnel
ORDER BY event_month;


/* =======================================================
2. session_journey
======================================================= */

SELECT
COUNT(*) AS total_sessions,
SUM(converted_flag) AS converted_sessions
FROM session_journey;

SELECT *
FROM session_journey
LIMIT 20;


/* =======================================================
3. brand_performance
======================================================= */

SELECT
COUNT(*) AS total_brands
FROM brand_performance;

SELECT *
FROM brand_performance
ORDER BY total_revenue DESC
LIMIT 20;


/* =======================================================
4. product_performance
======================================================= */

SELECT
COUNT(*) AS total_products
FROM product_performance;

SELECT *
FROM product_performance
ORDER BY total_revenue DESC
LIMIT 20;


/* =======================================================
5. price_band_performance
======================================================= */

SELECT *
FROM price_band_performance
ORDER BY price_band_order;


/* =======================================================
6. cohort_retention
======================================================= */

SELECT *
FROM cohort_retention
ORDER BY cohort_month,
month_number;