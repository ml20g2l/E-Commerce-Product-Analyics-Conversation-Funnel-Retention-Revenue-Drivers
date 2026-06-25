/*
===========================================================
Project:
E-commerce Product Analytics

File:
05_conversion_funnel.sql

Business Question:
Where do customers drop off before completing a purchase?

Purpose:
Build monthly funnel metrics across view, cart,
remove-from-cart, and purchase events.

Business Value:
Identify the biggest conversion drop-off points and create
Power BI-ready KPIs for conversion optimisation.

Output:
monthly_conversion_funnel

Author:
Geeyoon Lim
===========================================================
*/


DROP TABLE IF EXISTS monthly_conversion_funnel;

CREATE TABLE monthly_conversion_funnel AS
WITH monthly_funnel AS (
    SELECT
        event_month,

        COUNT(*) FILTER (WHERE event_type = 'view') AS view_events,
        COUNT(*) FILTER (WHERE event_type = 'cart') AS cart_events,
        COUNT(*) FILTER (WHERE event_type = 'remove_from_cart') AS remove_from_cart_events,
        COUNT(*) FILTER (WHERE event_type = 'purchase') AS purchase_events,

        COUNT(DISTINCT user_id) FILTER (WHERE event_type = 'view') AS view_users,
        COUNT(DISTINCT user_id) FILTER (WHERE event_type = 'cart') AS cart_users,
        COUNT(DISTINCT user_id) FILTER (WHERE event_type = 'remove_from_cart') AS remove_from_cart_users,
        COUNT(DISTINCT user_id) FILTER (WHERE event_type = 'purchase') AS purchase_users,

        COUNT(DISTINCT user_session) FILTER (WHERE event_type = 'view') AS view_sessions,
        COUNT(DISTINCT user_session) FILTER (WHERE event_type = 'cart') AS cart_sessions,
        COUNT(DISTINCT user_session) FILTER (WHERE event_type = 'remove_from_cart') AS remove_from_cart_sessions,
        COUNT(DISTINCT user_session) FILTER (WHERE event_type = 'purchase') AS purchase_sessions,

        SUM(price) FILTER (
            WHERE event_type = 'purchase'
              AND price > 0
        ) AS total_revenue

    FROM clean_events
    GROUP BY event_month
)

SELECT
    event_month,

    view_events,
    cart_events,
    remove_from_cart_events,
    purchase_events,

    view_users,
    cart_users,
    remove_from_cart_users,
    purchase_users,

    view_sessions,
    cart_sessions,
    remove_from_cart_sessions,
    purchase_sessions,

    ROUND(cart_users::numeric / NULLIF(view_users, 0), 4) AS view_to_cart_user_rate,
    ROUND(purchase_users::numeric / NULLIF(cart_users, 0), 4) AS cart_to_purchase_user_rate,
    ROUND(purchase_users::numeric / NULLIF(view_users, 0), 4) AS overall_user_conversion_rate,

    ROUND(cart_sessions::numeric / NULLIF(view_sessions, 0), 4) AS view_to_cart_session_rate,
    ROUND(purchase_sessions::numeric / NULLIF(cart_sessions, 0), 4) AS cart_to_purchase_session_rate,
    ROUND(purchase_sessions::numeric / NULLIF(view_sessions, 0), 4) AS overall_session_conversion_rate,

    ROUND(remove_from_cart_sessions::numeric / NULLIF(cart_sessions, 0), 4) AS cart_removal_session_rate,

    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(total_revenue / NULLIF(purchase_events, 0), 2) AS average_purchase_value

FROM monthly_funnel
ORDER BY event_month;