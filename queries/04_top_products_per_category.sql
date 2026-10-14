-- Top-2 products in every category by units sold (RANK() with PARTITION BY).
WITH product_sales AS (
    SELECT p.category, p.product_name, SUM(oi.quantity) AS units
    FROM order_items oi
    JOIN orders   o ON o.order_id   = oi.order_id
    JOIN products p ON p.product_id = oi.product_id
    WHERE o.status = 'delivered'
    GROUP BY p.category, p.product_name
),
ranked AS (
    SELECT *, RANK() OVER (PARTITION BY category ORDER BY units DESC) AS rnk
    FROM product_sales
)
SELECT category, product_name, units, rnk
FROM ranked
WHERE rnk <= 2
ORDER BY category, rnk;
