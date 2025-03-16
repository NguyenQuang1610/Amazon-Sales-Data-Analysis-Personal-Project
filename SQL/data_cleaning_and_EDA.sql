-- CREATE TABLE TO PREPARE FOR IMPORT
CREATE TABLE ecommerce_sales (
	index_number INT,
    order_ID VARCHAR(30) PRIMARY KEY,
    date DATE,
    ship_status VARCHAR(50),
    fulfilment VARCHAR(30),
    sales_channel VARCHAR(20),
    ship_service_level VARCHAR(30),
    style VARCHAR(10),
    SKU VARCHAR(40),
    category VARCHAR(20),
    size VARCHAR(10),
    ASIN VARCHAR(20),
    courier_status VARCHAR(20),
    quantity INT,
    currency VARCHAR(5),
    amount DECIMAL(10,2),
    ship_city VARCHAR(50),
    ship_state VARCHAR(30),
    ship_postal_code VARCHAR(10),
    ship_country VARCHAR(10),
    promotion_ids VARCHAR(2000),
    B2B BOOL,
    fulfilled_by VARCHAR(20)
    );

-- MODIFY COLUMNS
ALTER TABLE ecommerce_sales MODIFY COLUMN date VARCHAR(10);
ALTER TABLE ecommerce_sales MODIFY COLUMN B2B VARCHAR(10);
ALTER TABLE ecommerce_sales RENAME COLUMN `date` TO order_date;

-- ENABLE LOCAL INFILE & IMPORT OPTIMIZATION
SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;
SET GLOBAL bulk_insert_buffer_size = 256000000;
ALTER TABLE ecommerce_sales DISABLE KEYS;
SET SQL_SAFE_UPDATES = 0;
DELETE FROM ecommerce_sales;

-- LOAD DATA FOR FASTER IMPORT
LOAD DATA LOCAL INFILE "C:/Users/minhq/Downloads/DATA ANALYSIS/Full Datasets for Projects/Amazon Sale Report/SQL/Amazon Sale Report (Cleaned).csv"
INTO TABLE ecommerce_sales
FIELDS TERMINATED BY ','  
ENCLOSED BY '"'  
LINES TERMINATED BY '\n'	
IGNORE 1 ROWS; -- Skip header

SELECT * FROM ecommerce_sales_backup; 

-- CREATE BACKUP TABLE
CREATE TABLE ecommerce_sales_backup AS SELECT * FROM ecommerce_sales;

-- COUNT NULL VALUES
SELECT COUNT(order_id)
FROM ecommerce_sales
WHERE order_ID IS NULL;

-- FIND TOTAL SALES AMOUNT BY COUNTRY
SELECT ship_state, SUM(amount) total_sales
FROM ecommerce_sales
GROUP BY ship_state
ORDER BY total_sales DESC;

-- FIND AVERAGE ORDER QUANTITY PER FULFILLMENT TYPE
SELECT fulfilment, AVG(quantity)
FROM ecommerce_sales
GROUP BY fulfilment
ORDER BY fulfilment;

-- FIND MOST POPULAR PRODUCT CATEGORY
SELECT category, COUNT(category)
FROM ecommerce_sales
GROUP BY category
ORDER BY COUNT(category) DESC
LIMIT 1;

-- FIND TOP-SELLING SKU PER SALES CHANNEL
WITH ranked_sales AS (
	SELECT sales_channel,
		   SKU,
           SUM(quantity) AS total_sales,
           ROW_NUMBER() OVER(PARTITION BY sales_channel ORDER BY SUM(quantity) DESC) AS SKU_rank
	FROM ecommerce_sales
    GROUP BY sales_channel, SKU
    )
SELECT sales_channel, SKU, total_sales
FROM ranked_sales
WHERE SKU_rank = 1;

-- Create new column for correct date formatting
ALTER TABLE ecommerce_sales
ADD COLUMN order_date_new DATE;

UPDATE ecommerce_sales
SET order_date_new = STR_TO_DATE(order_date, '%m/%d/%Y');

ALTER TABLE ecommerce_sales DROP COLUMN order_date;
ALTER TABLE ecommerce_sales CHANGE order_date_new order_date DATE;

SELECT order_date_new
FROM ecommerce_sales;

DESCRIBE ecommerce_sales;

-- CALCULATE MOM GROWTH IN SALES
WITH monthly_sales AS (
	SELECT DISTINCT MONTHNAME(order_date) AS `month`, 
		   SUM(amount) AS month_sales,
		   LAG(SUM(amount)) OVER (ORDER BY MONTHNAME(order_date)) AS previous_sales
	FROM ecommerce_sales
	GROUP BY MONTHNAME(order_date) 
	ORDER BY MONTHNAME(order_date) ASC
)
SELECT `month`,
	   month_sales,
       previous_sales,
	   ROUND((((month_sales - previous_sales) / previous_sales) * 100), 2) AS mom_sales_growth
FROM monthly_sales;

-- RANK TOP-5 FASTEST GROWING PRODUCT CATEGORY
WITH sales_by_category_previous AS (
SELECT RANK() OVER (PARTITION BY MONTH(order_date) ORDER BY SUM(amount) DESC) AS `rank`,
	   category,
       MONTH(order_date) AS `month`,
	   SUM(amount) AS latest_month_sales,
       LAG(SUM(amount)) OVER (PARTITION BY category) AS previous_sales
FROM ecommerce_sales
GROUP BY category, MONTH(order_date)
ORDER BY SUM(amount) DESC
), 
sales_ranking AS (
SELECT /*RANK() OVER (PARTITION BY category ORDER BY (((latest_month_sales - previous_sales) / previous_sales) * 100) DESC) AS ranking, */
       category,
       `month`,
	   (((latest_month_sales - previous_sales) / previous_sales) * 100) AS growth_rate
FROM sales_by_category_previous
GROUP BY category, (((latest_month_sales - previous_sales) / previous_sales) * 100), `month`
ORDER BY (((latest_month_sales - previous_sales) / previous_sales) * 100)
)
SELECT RANK() OVER (ORDER BY growth_rate DESC) AS ranking,
	   category,
	   growth_rate
FROM sales_ranking
GROUP BY category, growth_rate
LIMIT 5;

-- IDENTIY ORDERS WITH DELAYED FULFILLMENT (based on Status and Courier Status)

WITH ship_status_table AS (
SELECT order_id,
	   CASE WHEN ship_status IN ('Pending - Waiting for Pick Up', 'Pending', 'Shipped - Lost in Transit') THEN 'Delayed - Not Shipped'
			WHEN ship_status LIKE 'Shipped%' AND courier_status IN ('Unshipped', 'Cancelled', '') THEN 'Delayed - Shipping Issue'
       ELSE 'On Trank'
       END AS shipping_status
FROM ecommerce_sales
)
SELECT order_id, shipping_status
FROM ship_status_table
WHERE shipping_status IN ('Delayed - Not Shipped', 'Delayed - Shipping Issue')
ORDER BY shipping_status;

-- ANALYZE THE IMPACT OF SHIPPING SERVICE LEVELS (ship_service_level) ON DELIVERY SUCCESS.
-- Counting orders by ship service level
WITH orders_count_by_service_level AS (
SELECT COUNT(order_id) orders_count, ship_service_level
FROM ecommerce_sales
GROUP BY ship_service_level
),
success_orders_count_by_service_level AS (
SELECT COUNT(order_id) successful_orders, ship_service_level
FROM ecommerce_sales 
WHERE ship_status IN ('Shipped', 'Shipped -Delivered to Buyer')
AND courier_status = 'Shipped'
GROUP BY ship_service_level
)
SELECT socbsl.ship_service_level, ((socbsl.successful_orders / ocbsl.orders_count) * 100) courier_success_rate
FROM success_orders_count_by_service_level socbsl
JOIN orders_count_by_service_level ocbsl ON socbsl.ship_service_level = ocbsl.ship_service_level;





