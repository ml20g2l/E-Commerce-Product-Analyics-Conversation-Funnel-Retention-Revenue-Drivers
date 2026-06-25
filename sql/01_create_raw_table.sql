SELECT
    cohort_month,
    MAX(CASE WHEN month_number = 0 THEN retention_rate END) AS month_0,
    MAX(CASE WHEN month_number = 1 THEN retention_rate END) AS month_1,
    MAX(CASE WHEN month_number = 2 THEN retention_rate END) AS month_2,
    MAX(CASE WHEN month_number = 3 THEN retention_rate END) AS month_3,
    MAX(CASE WHEN month_number = 4 THEN retention_rate END) AS month_4
FROM cohort_retention
GROUP BY cohort_month
ORDER BY cohort_month;