-- Monthly revenue and month-over-month growth using LAG().
WITH monthly AS (
    SELECT strftime('%Y-%m', o.order_date)          AS month,
           SUM(oi.quantity * oi.unit_price)         AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'delivered'
    GROUP BY month
)
SELECT
    month,
    ROUND(revenue, 0)                                                        AS revenue,
    ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
          / LAG(revenue) OVER (ORDER BY month), 1)                           AS mom_growth_pct,
    ROUND(SUM(revenue) OVER (ORDER BY month), 0)                             AS running_total
FROM monthly
ORDER BY month;
