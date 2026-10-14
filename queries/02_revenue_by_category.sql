-- Revenue and share of total by product category (JOIN + GROUP BY + window over the whole result).
SELECT
    p.category,
    ROUND(SUM(oi.quantity * oi.unit_price), 0)                                   AS revenue,
    ROUND(100.0 * SUM(oi.quantity * oi.unit_price)
          / SUM(SUM(oi.quantity * oi.unit_price)) OVER (), 1)                    AS share_pct
FROM order_items oi
JOIN orders   o ON o.order_id   = oi.order_id
JOIN products p ON p.product_id = oi.product_id
WHERE o.status = 'delivered'
GROUP BY p.category
ORDER BY revenue DESC;
