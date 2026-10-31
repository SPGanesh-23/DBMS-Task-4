USE flipkart_database;

-- Workbench safe-update mode blocks UPDATE statements that do not filter on a key
-- column (error 1175). Turn it off for this session.
SET SQL_SAFE_UPDATES = 0;

-- ============ 1. CREATE TABLES ============

-- Orders table: created in Task 1 (no change needed).
CREATE TABLE order_details (
    order_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id        INT NOT NULL,
    product_id      INT NOT NULL,
    quantity        INT NOT NULL,
    price           DECIMAL(10,2) NOT NULL,          
    CONSTRAINT chk_detail_quantity CHECK (quantity > 0),
    CONSTRAINT chk_detail_price    CHECK (price > 0),
    CONSTRAINT uq_order_product    UNIQUE (order_id, product_id),   
    CONSTRAINT fk_details_order    FOREIGN KEY (order_id)
        REFERENCES orders(order_id) ON DELETE CASCADE,
    CONSTRAINT fk_details_product  FOREIGN KEY (product_id)
        REFERENCES product(product_id)
);

-- ============ 2. CONSTRAINTS & RELATIONSHIPS ============
DESCRIBE orders;
DESCRIBE order_details;

-- ============ 3. SAMPLE DATA ============

-- 3.1 Order details for the 10 orders created in Task 1 (one product each).
INSERT INTO order_details (order_id, product_id, quantity, price) VALUES
(1,  1, 1, 17999.00),
(2,  2, 2,   499.00),
(3,  3, 1,  1899.00),
(4,  4, 3,   250.00),
(5,  5, 1,  1299.00),
(6,  6, 1,  1499.00),
(7,  7, 1,  3299.00),
(8,  8, 2,   199.00),
(9,  9, 1,   799.00),
(10, 10, 2,  350.00);

-- 3.2 Five new orders with several products each (order ids 11 to 15).
INSERT INTO orders (order_id, customer_id, order_date, total_amount, order_status) VALUES
(11, 3, '2026-10-11', 0.00, 'Delivered'),
(12, 1, '2026-10-12', 0.00, 'Shipped'),
(13, 2, '2026-10-13', 0.00, 'Pending'),
(14, 7, '2026-10-14', 0.00, 'Delivered'),
(15, 4, '2026-10-15', 0.00, 'Cancelled');

INSERT INTO order_details (order_id, product_id, quantity, price) VALUES
(11, 11, 1, 1799.00),   
(11, 13, 2, 1299.00),   
(11, 14, 1,  999.00),   
(12, 16, 1, 2299.00),   
(12, 15, 2,  699.00),   
(13, 17, 2,  399.00),   
(13, 18, 1,  499.00),   
(13, 19, 1,  699.00),   
(14, 12, 1, 2499.00),   
(14,  6, 1, 1499.00),   
(15, 20, 2,  349.00),   
(15,  8, 1,  199.00);   

UPDATE orders o
JOIN (SELECT order_id, SUM(quantity * price) AS order_total
      FROM order_details
      GROUP BY order_id) d ON o.order_id = d.order_id
SET o.total_amount = d.order_total;

SELECT * FROM order_details;
SELECT order_id, customer_id, order_date, total_amount, order_status FROM orders;

-- ============ 4. ORDER MANAGEMENT OPERATIONS ============

-- 4.1 Create a new order for a customer, add several products and calculate the total
INSERT INTO orders (customer_id, order_date, total_amount)
VALUES (6, '2026-10-16', 0.00);
SET @new_order_id = LAST_INSERT_ID();

INSERT INTO order_details (order_id, product_id, quantity, price) VALUES
(@new_order_id, 7, 1, (SELECT price FROM product WHERE product_id = 7)),   
(@new_order_id, 3, 1, (SELECT price FROM product WHERE product_id = 3));   

SELECT order_id, SUM(quantity * price) AS calculated_total
FROM order_details
WHERE order_id = @new_order_id
GROUP BY order_id;

UPDATE orders
SET total_amount = (SELECT SUM(quantity * price) FROM order_details WHERE order_id = @new_order_id)
WHERE order_id = @new_order_id;

UPDATE orders SET order_status = 'Shipped' WHERE order_id = @new_order_id;

SELECT o.order_id, o.order_date, o.order_status, p.product_name,
       od.quantity, od.price, od.quantity * od.price AS line_total, o.total_amount
FROM orders o
JOIN order_details od ON o.order_id   = od.order_id
JOIN product p        ON od.product_id = p.product_id
WHERE o.order_id = @new_order_id;

-- 4.2 Update order status (Pending -> Shipped -> Delivered)
UPDATE orders SET order_status = 'Shipped'   WHERE order_id = 13;   
UPDATE orders SET order_status = 'Delivered' WHERE order_id = 12;   
UPDATE orders SET order_status = 'Delivered' WHERE order_id = 5;    
SELECT order_id, order_status FROM orders WHERE order_id IN (5, 12, 13);

-- 4.3 Update the quantity of an ordered product, then recalculate the order total
UPDATE order_details SET quantity = 3 WHERE order_id = 13 AND product_id = 17;

UPDATE orders
SET total_amount = (SELECT SUM(quantity * price) FROM order_details WHERE order_id = 13)
WHERE order_id = 13;

SELECT od.order_id, p.product_name, od.quantity, od.price, o.total_amount
FROM order_details od
JOIN orders  o ON od.order_id   = o.order_id
JOIN product p ON od.product_id = p.product_id
WHERE od.order_id = 13;

-- 4.4 Delete cancelled orders
SELECT order_id, customer_id, total_amount, order_status FROM orders WHERE order_status = 'Cancelled';
SELECT * FROM order_details WHERE order_id = 15;

DELETE FROM orders WHERE order_id = 15 AND order_status = 'Cancelled';

SELECT * FROM order_details WHERE order_id = 15;

-- 4.5 Display complete order information with customer and product details
SELECT o.order_id, o.order_date, o.order_status,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name, c.city,
       p.product_name, od.quantity, od.price,
       od.quantity * od.price AS line_total, o.total_amount
FROM orders o
JOIN customer c       ON o.customer_id = c.customer_id
JOIN order_details od ON o.order_id    = od.order_id
JOIN product p        ON od.product_id = p.product_id
ORDER BY o.order_id, p.product_name;

-- ============ 5. CUSTOMER ORDER HISTORY & SALES ANALYSIS ============

-- 5.1 Customer order history (all orders, including cancelled ones)
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       o.order_id, o.order_date, o.order_status, o.total_amount
FROM customer c
JOIN orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_id, o.order_date;

-- 5.2 Product-wise order report (Cancelled orders are ignored)
SELECT p.product_name, o.order_id,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       od.quantity, od.price, od.quantity * od.price AS line_total
FROM order_details od
JOIN orders o   ON od.order_id   = o.order_id
JOIN product p  ON od.product_id = p.product_id
JOIN customer c ON o.customer_id = c.customer_id
WHERE o.order_status <> 'Cancelled'
ORDER BY p.product_name, o.order_id;

-- 5.3 Number of times each product was ordered
SELECT p.product_id, p.product_name,
       COUNT(DISTINCT od.order_id)  AS times_ordered,
       SUM(od.quantity)             AS total_quantity,
       SUM(od.quantity * od.price)  AS total_revenue
FROM product p
JOIN order_details od ON p.product_id = od.product_id
JOIN orders o         ON od.order_id  = o.order_id
WHERE o.order_status <> 'Cancelled'
GROUP BY p.product_id, p.product_name
ORDER BY times_ordered DESC, total_quantity DESC, p.product_name;

-- 5.3b Products that have never been ordered (in a valid order)
SELECT p.product_id, p.product_name
FROM product p
WHERE NOT EXISTS (SELECT 1
                  FROM order_details od
                  JOIN orders o ON od.order_id = o.order_id
                  WHERE od.product_id = p.product_id
                    AND o.order_status <> 'Cancelled')
ORDER BY p.product_id;

-- 5.4 Total quantity of products sold
SELECT SUM(od.quantity) AS total_quantity_sold
FROM order_details od
JOIN orders o ON od.order_id = o.order_id
WHERE o.order_status <> 'Cancelled';

-- 5.5 Customers with the maximum number of orders
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       COUNT(o.order_id) AS total_orders
FROM customer c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_status <> 'Cancelled'
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(o.order_id) = (SELECT MAX(order_count)
                            FROM (SELECT COUNT(*) AS order_count
                                  FROM orders
                                  WHERE order_status <> 'Cancelled'
                                  GROUP BY customer_id) AS counts);

-- 5.6 Total spending by each customer
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       COUNT(o.order_id)                  AS total_orders,
       COALESCE(SUM(o.total_amount), 0)   AS total_spent
FROM customer c
LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.order_status <> 'Cancelled'
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC, c.customer_id;

-- 5.7 Average order value
SELECT ROUND(AVG(total_amount), 2) AS average_order_value
FROM orders
WHERE order_status <> 'Cancelled';

-- 5.8 Total sales amount
SELECT SUM(total_amount) AS total_sales_amount
FROM orders
WHERE order_status <> 'Cancelled';

-- 5.9 Orders and sales by status (used for the analysis report in the document)
SELECT order_status, COUNT(*) AS total_orders, SUM(total_amount) AS total_amount
FROM orders
GROUP BY order_status
ORDER BY FIELD(order_status, 'Pending', 'Shipped', 'Delivered', 'Cancelled');