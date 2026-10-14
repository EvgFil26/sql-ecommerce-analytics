-- Online store: customers place orders, each order has several items.
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id   INTEGER PRIMARY KEY,
    name          TEXT    NOT NULL,
    city          TEXT    NOT NULL,
    signup_date   DATE    NOT NULL,
    channel       TEXT    NOT NULL CHECK (channel IN ('organic', 'ads', 'referral'))
);

CREATE TABLE products (
    product_id    INTEGER PRIMARY KEY,
    product_name  TEXT    NOT NULL,
    category      TEXT    NOT NULL,
    price         REAL    NOT NULL CHECK (price > 0)
);

CREATE TABLE orders (
    order_id      INTEGER PRIMARY KEY,
    customer_id   INTEGER NOT NULL REFERENCES customers (customer_id),
    order_date    DATE    NOT NULL,
    status        TEXT    NOT NULL CHECK (status IN ('delivered', 'cancelled', 'returned'))
);

CREATE TABLE order_items (
    order_id      INTEGER NOT NULL REFERENCES orders (order_id),
    product_id    INTEGER NOT NULL REFERENCES products (product_id),
    quantity      INTEGER NOT NULL CHECK (quantity > 0),
    unit_price    REAL    NOT NULL,
    PRIMARY KEY (order_id, product_id)
);

CREATE INDEX idx_orders_customer ON orders (customer_id);
CREATE INDEX idx_orders_date     ON orders (order_date);
CREATE INDEX idx_items_product   ON order_items (product_id);
