/*
===========================================================
Power BI Funnel View
Purpose:
Create a simple funnel table for Power BI visualisation.

Output:
conversion_funnel
===========================================================
*/

DROP VIEW IF EXISTS conversion_funnel;

CREATE VIEW conversion_funnel AS
SELECT
    1 AS stage_order,
    'View' AS funnel_stage,
    SUM(view_sessions) AS sessions
FROM monthly_conversion_funnel

UNION ALL

SELECT
    2 AS stage_order,
    'Cart' AS funnel_stage,
    SUM(cart_sessions) AS sessions
FROM monthly_conversion_funnel

UNION ALL

SELECT
    3 AS stage_order,
    'Purchase' AS funnel_stage,
    SUM(purchase_sessions) AS sessions
FROM monthly_conversion_funnel;