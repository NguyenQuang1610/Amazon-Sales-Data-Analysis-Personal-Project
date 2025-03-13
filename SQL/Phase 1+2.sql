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
SET SQL_SAFE_UPDATES = 1;
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

-- 
           






