CREATE DATABASE creamy_g

-- customers
-- ------------------------------------------------------------
CREATE TABLE customers (
    customer_id   INTEGER PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    email         VARCHAR(150),
    city          VARCHAR(80)
);

-- ------------------------------------------------------------
-- products
-- ------------------------------------------------------------
CREATE TABLE products (
    product_id    INTEGER PRIMARY KEY,
    product_name  VARCHAR(120) NOT NULL,
    category      VARCHAR(60),
    price         NUMERIC(12,2)
);

-- ------------------------------------------------------------
-- orders  (customer_id NOT enforced as FK on purpose)
-- ------------------------------------------------------------
CREATE TABLE orders (
    order_id      INTEGER PRIMARY KEY,
    customer_id   INTEGER,          -- may be NULL or point to a non-existent customer
    order_date    DATE,
    total_amount  NUMERIC(12,2)
);

-- ------------------------------------------------------------
-- order_items (order_id / product_id NOT enforced as FK on purpose)
-- ------------------------------------------------------------
CREATE TABLE order_items (
    order_item_id INTEGER PRIMARY KEY,
    order_id      INTEGER,          -- may point to a non-existent order
    product_id    INTEGER,          -- may be NULL or point to a non-existent product
    quantity      INTEGER,
    unit_price    NUMERIC(12,2)
);

-- ============================================================
-- SEED DATA
-- ============================================================

-- ---------------- customers ----------------
INSERT INTO customers (customer_id, name, email, city) VALUES
(1,  'Chinedu Okeke',      'chinedu.okeke@gmail.com',   'Lagos'),
(2,  'Amaka Eze',          'amaka.eze@yahoo.com',       'Enugu'),
(3,  'Tunde Bakare',       'tunde.bakare@gmail.com',    'Ibadan'),
(4,  'Ngozi Madu',         'ngozi.madu@outlook.com',    'Port Harcourt'),
(5,  'Ibrahim Sani',       'ibrahim.sani@gmail.com',    'Kano'),
(6,  'Funke Adeyemi',      'funke.adeyemi@gmail.com',   'Abeokuta'),
(7,  'Emeka Nwosu',        'emeka.nwosu@gmail.com',     'Onitsha'),
(8,  'Halima Bello',       'halima.bello@yahoo.com',    'Kaduna'),
-- customers 9 & 10 will have NO orders (for Q5)
(9,  'Olu Fadeyi',         'olu.fadeyi@gmail.com',      'Akure'),
(10, 'Zainab Yusuf',       'zainab.yusuf@gmail.com',    'Maiduguri');

-- ---------------- products ----------------
INSERT INTO products (product_id, product_name, category, price) VALUES
(101, 'Tecno Spark 20',        'Electronics',   145000.00),
(102, 'Itel Power Bank 20000', 'Electronics',    18500.00),
(103, 'HP Pavilion Laptop',    'Electronics',   650000.00),
(104, 'Ankara Fabric (6 yds)', 'Fashion',        12000.00),
(105, 'Leather Sandals',       'Fashion',        15500.00),
(106, 'Golden Penny Semovita', 'Groceries',       8500.00),
(107, 'Peak Milk Tin (carton)','Groceries',      14000.00),
(108, 'Office Swivel Chair',   'Furniture',      45000.00),
-- products 109 & 110 will be NEVER ordered (for Q6)
(109, 'Standing Desk',         'Furniture',     120000.00),
(110, 'Ceramic Dinner Set',    'Home',           22000.00);

-- ---------------- orders ----------------
-- Valid orders (customer exists)
INSERT INTO orders (order_id, customer_id, order_date, total_amount) VALUES
(1001, 1, '2025-01-05', 163500.00),
(1002, 1, '2025-02-11', 650000.00),
(1003, 2, '2025-01-20',  27500.00),
(1004, 3, '2025-03-02', 145000.00),
(1005, 4, '2025-03-15',  22500.00),
(1006, 5, '2025-04-01',  59000.00),
(1007, 6, '2025-04-10',  14000.00),
(1008, 7, '2025-05-05',  31000.00),
(1009, 8, '2025-05-18',  45000.00),
-- INTENTIONAL ANOMALY: customer_id 999 does not exist (orphan order) — for Q3, Q4, Q7
(1010, 999, '2025-05-22', 18500.00),
-- INTENTIONAL ANOMALY: customer_id IS NULL (missing reference) — for Q3, Q4, Q7
(1011, NULL, '2025-05-25', 90000.00);

-- ---------------- order_items ----------------
-- Valid order_items (order + product both exist)
INSERT INTO order_items (order_item_id, order_id, product_id, quantity, unit_price) VALUES
(1, 1001, 101, 1, 145000.00),   -- Tecno Spark
(2, 1001, 102, 1,  18500.00),   -- Power Bank
(3, 1002, 103, 1, 650000.00),   -- HP Laptop
(4, 1003, 104, 1,  12000.00),   -- Ankara
(5, 1003, 105, 1,  15500.00),   -- Sandals
(6, 1004, 101, 1, 145000.00),   -- Tecno Spark
(7, 1005, 105, 1,  15500.00),   -- Sandals (Fashion) for Ngozi
(8, 1006, 108, 1,  45000.00),   -- Swivel Chair
(9, 1006, 102, 1,  18500.00),   -- Power Bank (NOTE qty/price create reconciliation diff for Q17)
(10,1007, 107, 1,  14000.00),   -- Peak Milk
(11,1008, 105, 2,  15500.00),   -- Sandals x2
(12,1009, 108, 1,  45000.00),   -- Swivel Chair
-- Electronics + other category for Chinedu (cust 1) already: order 1001 Electronics, need a non-Electronics too
(13,1002, 106, 2,   8500.00),   -- Semovita on order 1002 -> cust 1 now has Electronics + Groceries (Q18)
-- INTENTIONAL ANOMALY: order_id 8888 does not exist (orphan item) — for Q14, Q15
(14, 8888, 101, 1, 145000.00),
-- INTENTIONAL ANOMALY: product_id 7777 does not exist (invalid product) — for Q10, Q14, Q15
(15, 1004, 7777, 3, 10000.00),
-- INTENTIONAL ANOMALY: product_id IS NULL (missing product) — for Q10, Q14
(16, 1007, NULL, 1, 5000.00);


SELECT *
FROM customers

SELECT *
FROM products

SELECT *
FROM orders

SELECT *
FROM order_items

/*Q1. List customer names along with their order IDs and order dates. Only 
	include customers who have placed at least one order.
*/
SELECT name, order_id, order_date 
FROM customers 
NATURAL JOIN orders;  --Natural inner join

/*Q2. Display all customers with their names and emails, and include any 
	associated order ID and date if available, even if the customer hasn't 
	placed any orders.
*/
SELECT name, email, order_id, order_date 
FROM customers 
NATURAL LEFT JOIN orders; -- Natural Left Join

/*Q3. Show all orders with their IDs, dates, and total amounts, alongside the 
	customer name if the order references a valid customer. Include all orders 
	even if the customer reference is invalid or missing.
*/
SELECT order_id, order_date, total_amount, name 
FROM customers 
NATURAL RIGHT JOIN orders; --Natural Right Join

/*Q4. Create a comprehensive view of customer-to-order relationships showing 
	all customers and orders, including customers without orders and orders 
	without valid customer references.
*/
SELECT *
FROM customers
NATURAL FULL JOIN orders; --Natural Full Join

/*Q5. Identify customers who have not placed any orders. Display their names,
	emails, and cities.
*/
SELECT name, email, city
FROM customers 
NATURAL LEFT JOIN orders
WHERE order_id IS NULL;

/*Q6. Find products that have never been included in any order, showing product
	name, category, and price.
*/
SELECT p.*
FROM products p
NATURAL LEFT JOIN order_items oi
WHERE order_id IS NULL;

/*Q7. Retrieve orders that have invalid or missing customer references, 
	including order ID, customer ID, order date, and total amount.
*/
SELECT order_id, customer_id, order_date, total_amount 
FROM customers 
NATURAL RIGHT JOIN orders
WHERE name IS NULL; 

/*Q8. Show customer name, order date, and product name for all transactions
	where the customer, order, and product all exist. Exclude any orphaned or 
	invalid records.
*/
SELECT name, order_date, product_name
FROM customers
NATURAL JOIN orders
NATURAL JOIN order_items
NATURAL JOIN products;

/*Q9. Display all customers and their order info, but only include records with
	valid products. Show customer name, order date, product name, and quantity.
*/
SELECT name, order_date, product_name, quantity
FROM customers
NATURAL LEFT JOIN orders
NATURAL LEFT JOIN order_items
NATURAL JOIN products;

/*Q10. List customer name, order date, product name, category, quantity, and 
	unit price for all order items. For orphaned or invalid references, 
	substitute "Unknown Customer" or "Unknown Product" accordingly.
*/
SELECT 
	COALESCE (name, 'Unknown Customer') customer_name,
	order_date,
	COALESCE (product_name, 'Unknown Product') product_name,
	category,
	quantity,
	unit_price
FROM order_items
NATURAL LEFT JOIN products
NATURAL LEFT JOIN orders
NATURAL LEFT JOIN customers;

/*Q11. For each customer, including those with no orders, show:
	-Customer name
	-Number of orders placed
	-Total amount spent
	Use zero for customers without orders.
*/
SELECT 
	name, 
	COUNT (DISTINCT o.order_id) number_of_orders,
	COALESCE (SUM(quantity * unit_price), 0) total_amount_spent
FROM customers c
NATURAL LEFT JOIN orders o
NATURAL LEFT JOIN order_items oi
GROUP BY customer_id, name
ORDER BY customer_id;

/*Q12. Summarize sales for each product, including those never sold, with:
	Product name and category
	Total quantity sold (0 if none)
	Total revenue generated (0 if none)
*/
SELECT 
	product_name, 
	category,
	COALESCE (SUM(quantity), 0) total_quantity_sold, 
	COALESCE (SUM(quantity * unit_price), 0) total_revenue_generated
FROM products
NATURAL LEFT JOIN order_items
GROUP BY product_id, product_name
ORDER BY product_id;

/*Q13. For each product category, identify:
	Total number of products in the category
	Number of products sold from that category
	Number of unsold products from that category
*/
SELECT 
	category,
	COUNT(DISTINCT product_name) total_products_per_category,
	COUNT(DISTINCT quantity) total_products_sold_per_category,
	COUNT(DISTINCT CASE 
		WHEN quantity IS NULL THEN p.product_id 
		END) total_products_unsold_per_category
FROM products p
NATURAL LEFT JOIN order_items oi
GROUP BY category
ORDER BY category;

/*Q14. Produce a report showing:
	Number of orders without valid customers
	Number of order items without valid orders
	Number of order items without valid products
*/
SELECT
	COUNT(DISTINCT o.order_id) FILTER (
		WHERE c.customer_id IS NULL
	) orders_without_valid_customers,

	COUNT (DISTINCT oi.order_item_id) FILTER (
		WHERE o.order_id IS NULL
	) order_items_without_valid_orders,

	COUNT (DISTINCT oi.order_item_id) FILTER (
		WHERE p.product_id IS NULL
	) order_items_without_valid_products
FROM orders o
NATURAL FULL JOIN customers c
NATURAL FULL JOIN order_items oi
NATURAL FULL JOIN products p;

/*Q15. Create a combined report that labels all problematic relationships, such
	as:
	Customers with no orders
	Orders without customers
	Products with no sales
	Order items with invalid orders or products
*/
SELECT 'customers with no orders' AS issue_type, COUNT(*) AS count
FROM customers c
NATURAL LEFT JOIN orders o
WHERE o.customer_id IS NULL 

UNION ALL

SELECT 'order without customers' AS issue_type, COUNT (*) AS count
FROM orders o 
NATURAL LEFT JOIN customers c
WHERE c.customer_id IS NULL

UNION ALL

SELECT 'products with no sales' AS issue_type, COUNT (*) AS count
FROM products p
NATURAL LEFT JOIN order_items oi
WHERE oi.product_id IS NULL

UNION ALL

SELECT 'order items with invalid orders' AS issue_type, COUNT(*) AS count
FROM order_items oi
NATURAL LEFT JOIN orders o
WHERE o.order_id IS NULL

UNION ALL

SELECT 'order items with invalid products' AS issue_type, COUNT(*) AS count
FROM order_items oi
NATURAL LEFT JOIN products p
WHERE p.product_id IS NULL;


/*Q16. Find customers who have placed orders and, for each, determine:
	Customer name
	Count of distinct product categories purchased from
	List of categories as a comma-separated string
*/
SELECT 
	name,
	COUNT(DISTINCT category) category_count,
	STRING_AGG(DISTINCT category, ', ') categories
FROM customers
NATURAL JOIN orders
NATURAL JOIN order_items
NATURAL JOIN products
GROUP BY name
ORDER BY name;

/*Q17. Compare each order's total amount (from the order table) with the sum
	of (quantity × unit_price) from associated order items. Show order ID, 
	stated total, calculated total, and the difference. Only include valid 
	customer orders with at least one order item.
*/
SELECT 
	order_id, 
	total_amount, 
	SUM(quantity * unit_price) calculated_total,
	ABS(total_amount - SUM(quantity * unit_price)) difference
FROM orders
NATURAL JOIN order_items
NATURAL JOIN products
GROUP BY order_id
ORDER BY order_id;

/*Q18. Identify customers who have:
	Placed at least one order
	Ordered products from the 'Electronics' category
	Also ordered products from at least one other category
*/
SELECT 
	customer_id, 
	name,
	STRING_AGG(DISTINCT category, ', ') categories
FROM customers
NATURAL JOIN orders
NATURAL JOIN order_items
NATURAL JOIN products
GROUP BY customer_id, name
HAVING 
	COUNT(CASE WHEN category = 'Electronics' THEN 1 END) > 0
	AND COUNT(CASE WHEN category <> 'Electronics' THEN 1 END) > 0;