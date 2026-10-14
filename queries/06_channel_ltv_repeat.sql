-- Acquisition channel quality: lifetime value and share of repeat customers.
WITH customer_stats AS (
    SELECT c.customer_id, c.channel,
           COUNT(DISTINCT o.order_id)                    AS n_orders,
           COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS ltv
    FROM customers c
    LEFT JOIN orders o       ON o.customer_id = c.customer_id AND o.status = 'delivered'
    LEFT JOIN order_items oi ON oi.order_id   = o.order_id
    GROUP BY c.customer_id, c.channel
)
SELECT
    channel,
    COUNT(*)                                                    AS customers,
    ROUND(AVG(ltv), 0)                                          AS avg_ltv,
    ROUND(100.0 * SUM(CASE WHEN n_orders >= 2 THEN 1 ELSE 0 END) / COUNT(*), 1) AS repeat_rate_pct
FROM customer_stats
GROUP BY channel
ORDER BY avg_ltv DESC;
