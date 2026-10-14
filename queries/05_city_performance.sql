-- Cities with more than 100 customers: customers, orders per customer, revenue per customer (HAVING).
SELECT
    c.city,
    COUNT(DISTINCT c.customer_id)                                            AS customers,
    ROUND(1.0 * COUNT(DISTINCT o.order_id) / COUNT(DISTINCT c.customer_id), 2) AS orders_per_customer,
    ROUND(SUM(oi.quantity * oi.unit_price) / COUNT(DISTINCT c.customer_id), 0) AS revenue_per_customer
FROM customers c
JOIN orders o       ON o.customer_id = c.customer_id AND o.status = 'delivered'
JOIN order_items oi ON oi.order_id   = o.order_id
GROUP BY c.city
HAVING COUNT(DISTINCT c.customer_id) > 100
ORDER BY revenue_per_customer DESC;
