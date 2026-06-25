/*
===========================================================
Project:
E-commerce Product Analytics

File:
09_cohort_retention.sql

Business Question:
Do customers return after their first month of activity?

Purpose:
Build a monthly cohort retention table based on each
customer's first activity month.

Business Value:
Measure repeat engagement and identify whether the product
retains customers beyond their first visit.

Input:
clean_events

Output:
cohort_retention

Author:
Geeyoon Lim
===========================================================
*/


DROP TABLE IF EXISTS cohort_retention;

CREATE TABLE cohort_retention AS
WITH user_first_month AS (
    SELECT
        user_id,
        MIN(event_month) AS cohort_month
    FROM clean_events
    GROUP BY user_id
),

user_activity AS (
    SELECT DISTINCT
        user_id,
        event_month AS activity_month
    FROM clean_events
),

cohort_activity AS (
    SELECT
        f.user_id,
        f.cohort_month,
        a.activity_month,

        (
            EXTRACT(YEAR FROM AGE(a.activity_month, f.cohort_month)) * 12
            + EXTRACT(MONTH FROM AGE(a.activity_month, f.cohort_month))
        )::int AS month_number

    FROM user_first_month f
    JOIN user_activity a
        ON f.user_id = a.user_id
    WHERE a.activity_month >= f.cohort_month
),

cohort_sizes AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT user_id) AS cohort_size
    FROM user_first_month
    GROUP BY cohort_month
)

SELECT
    c.cohort_month,
    c.activity_month,
    c.month_number,
    s.cohort_size,
    COUNT(DISTINCT c.user_id) AS active_users,

    ROUND(
        COUNT(DISTINCT c.user_id)::numeric
        / NULLIF(s.cohort_size, 0),
        4
    ) AS retention_rate

FROM cohort_activity c
JOIN cohort_sizes s
    ON c.cohort_month = s.cohort_month
GROUP BY
    c.cohort_month,
    c.activity_month,
    c.month_number,
    s.cohort_size
ORDER BY
    c.cohort_month,
    c.month_number;