/*
Project:
E-commerce Product Analytics

Purpose:
Create an analysis-ready view by converting data types,
adding derived date fields,
and keeping the raw table unchanged.

Author: Geeyoon Lim
*/

CREATE VIEW clean_events AS
SELECT
    event_time::timestamp AS event_time,

    DATE(event_time::timestamp) AS event_date,

    DATE_TRUNC('month', event_time::timestamp)::date
        AS event_month,

    event_type,

    product_id,

    category_id,

    category_code,

    brand,

    price,

    user_id,

    user_session

FROM raw_events

WHERE
    user_id IS NOT NULL
    AND user_session IS NOT NULL
    AND event_type IS NOT NULL;