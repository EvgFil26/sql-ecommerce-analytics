-- Business KPIs for delivered orders: revenue, orders, customers, average order value (AOV).
WITH order_totals AS (
    SELECT o.order_id, o.customer_id, SUM(oi.quantity * oi.unit_price) AS order_value
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    WHERE o.status = 'delivered'
    GROUP BY o.order_id, o.customer_id
)
SELECT
    ROUND(SUM(order_value), 0)              AS revenue,
    COUNT(*)                                AS orders,
    COUNT(DISTINCT customer_id)             AS customers,
    ROUND(AVG(order_value), 0)              AS avg_order_value
FROM order_totals;
