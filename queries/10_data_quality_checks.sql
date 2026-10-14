-- Data quality checks: every row should return 0.
SELECT 'orders without items'          AS check_name, COUNT(*) AS problems
FROM orders o LEFT JOIN order_items oi ON oi.order_id = o.order_id
WHERE oi.order_id IS NULL
UNION ALL
SELECT 'orders before customer signup', COUNT(*)
FROM orders o JOIN customers c ON c.customer_id = o.customer_id
WHERE o.order_date < c.signup_date
UNION ALL
SELECT 'items priced above list price', COUNT(*)
FROM order_items oi JOIN products p ON p.product_id = oi.product_id
WHERE oi.unit_price > p.price
UNION ALL
SELECT 'duplicate customer ids', COUNT(*) - COUNT(DISTINCT customer_id)
FROM customers;
