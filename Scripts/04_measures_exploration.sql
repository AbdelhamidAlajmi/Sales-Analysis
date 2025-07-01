-- Measures Exploration
-- Find the Total Sales
SELECT
	SUM(SALES_AMOUNT) AS TOTAL_SALES
FROM
	FACT_SALES;

-- How Many Items are sold
SELECT
	SUM(QUANTITY) AS TOTAL_QUANTITY
FROM
	FACT_SALES;

-- Find the average selling price
SELECT
	ROUND(AVG(PRICE), 2) AS AVG_PRICE
FROM
	FACT_SALES;

-- Find The Total number of orders
SELECT
	COUNT(DISTINCT ORDER_NUMBER) AS TOTAL_ORDERS
FROM
	FACT_SALES;

-- Find the total number of products
SELECT
	COUNT(PRODUCT_ID) AS TOTAL_PRODUCTS
FROM
	DIM_PRODUCTS;

-- Find the total number of customers
SELECT
	COUNT(CUSTOMER_ID) AS TOTAL_CUSTOMERS
FROM
	DIM_CUSTOMERS;

-- find the total number of customers that has placed an order
SELECT
	COUNT(DISTINCT CUSTOMER_KEY) AS TOTAL_RUNNING_CUSTOMERS
FROM
	FACT_SALES;

---------------------------------------------------------------------------
-- Generate a Report that shows all key metrics of the business
SELECT
	'Total Sales' AS MEASURE_NAME,
	SUM(SALES_AMOUNT) AS MEASURE_VALUE
FROM
	FACT_SALES
UNION ALL
SELECT
	'Total Quantity',
	SUM(QUANTITY)
FROM
	FACT_SALES
UNION ALL
SELECT
	'Average Price',
	ROUND(AVG(PRICE), 2)
FROM
	FACT_SALES
UNION ALL
SELECT
	'Total # Orders',
	COUNT(DISTINCT ORDER_NUMBER)
FROM
	FACT_SALES
UNION ALL
SELECT
	'Total # Products',
	COUNT(PRODUCT_ID)
FROM
	DIM_PRODUCTS
UNION ALL
SELECT
	'Total # Customers',
	COUNT(CUSTOMER_ID)
FROM
	DIM_CUSTOMERS;
