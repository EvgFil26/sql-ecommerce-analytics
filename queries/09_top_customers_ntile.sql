-- Customer segmentation by revenue deciles (NTILE) and how much the top 10% bring.
WITH customer_revenue AS (
    SELECT o.customer_id, SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'delivered'
    GROUP BY o.customer_id
),
deciles AS (
    SELECT *, NTILE(10) OVER (ORDER BY revenue DESC) AS decile
    FROM customer_revenue
)
SELECT
    decile,
    COUNT(*)                                                         AS customers,
    ROUND(SUM(revenue), 0)                                           AS revenue,
    ROUND(100.0 * SUM(revenue) / (SELECT SUM(revenue) FROM customer_revenue), 1) AS share_pct
FROM deciles
GROUP BY decile
ORDER BY decile;
