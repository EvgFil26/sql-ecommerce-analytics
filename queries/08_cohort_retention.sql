-- Monthly cohorts: % of customers from each first-order month who ordered again 1, 2 and 3 months later.
WITH first_order AS (
    SELECT customer_id, MIN(strftime('%Y-%m', order_date)) AS cohort
    FROM orders
    WHERE status = 'delivered'
    GROUP BY customer_id
),
activity AS (
    SELECT DISTINCT o.customer_id, f.cohort,
           (CAST(strftime('%Y', o.order_date) AS INT) * 12 + CAST(strftime('%m', o.order_date) AS INT))
         - (CAST(substr(f.cohort, 1, 4)       AS INT) * 12 + CAST(substr(f.cohort, 6, 2)       AS INT)) AS month_n
    FROM orders o
    JOIN first_order f ON f.customer_id = o.customer_id
    WHERE o.status = 'delivered'
)
SELECT
    cohort,
    COUNT(DISTINCT CASE WHEN month_n = 0 THEN customer_id END)                                   AS cohort_size,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN month_n = 1 THEN customer_id END)
          / COUNT(DISTINCT CASE WHEN month_n = 0 THEN customer_id END), 1)                       AS m1_pct,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN month_n = 2 THEN customer_id END)
          / COUNT(DISTINCT CASE WHEN month_n = 0 THEN customer_id END), 1)                       AS m2_pct,
    ROUND(100.0 * COUNT(DISTINCT CASE WHEN month_n = 3 THEN customer_id END)
          / COUNT(DISTINCT CASE WHEN month_n = 0 THEN customer_id END), 1)                       AS m3_pct
FROM activity
WHERE cohort <= '2026-03'
GROUP BY cohort
ORDER BY cohort;
