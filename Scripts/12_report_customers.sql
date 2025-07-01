-- Build Customer Report
/*
===============================================================================
Customer Report
===============================================================================
Purpose:
- This report consolidates key customer metrics and behaviors

Highlights:
1. Gathers essential fields such as names, ages, and transaction details.
2. Segments customers into categories (VIP, Regular, New) and age groups.
3. Aggregates customer-level metrics:
- total orders
- total sales
- total quantity purchased
- total products
- lifespan (in months)
4. Calculates valuable KPIs:
- recency (months since last order)
- average order value
- average monthly spend
===============================================================================*/
CREATE VIEW REPORT_CUSTOMERS AS
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
---------------------------------------------------------------------------*/
WITH
	BASE_QUERY AS (
		/*---------------------------------------------------------------------------
		1) Base Query: Retrieves core columns from tables
		---------------------------------------------------------------------------*/
		SELECT
			S.ORDER_NUMBER,
			S.PRODUCT_KEY,
			S.ORDER_DATE,
			S.SALES_AMOUNT,
			S.QUANTITY,
			C.CUSTOMER_KEY,
			C.CUSTOMER_NUMBER,
			CONCAT(C.FIRST_NAME, ' ', C.LAST_NAME) AS CUSTOMER_NAME,
			EXTRACT(
				YEAR
				FROM
					AGE (C.BIRTHDATE)
			) AS AGE
		FROM
			FACT_SALES S
			JOIN DIM_CUSTOMERS C ON S.CUSTOMER_KEY = C.CUSTOMER_KEY
		WHERE
			S.ORDER_DATE IS NOT NULL
	),
	CUSTOMER_AGG AS (
		/*---------------------------------------------------------------------------
		2) Customer Aggregations: Summarizes key metrics at the customer level
		---------------------------------------------------------------------------*/
		SELECT
			CUSTOMER_KEY,
			CUSTOMER_NAME,
			CUSTOMER_NUMBER,
			AGE,
			COUNT(DISTINCT ORDER_NUMBER) AS TOTAL_ORDERS,
			SUM(SALES_AMOUNT) AS TOTAL_SALES,
			SUM(QUANTITY) AS TOTAL_QUANTITY,
			COUNT(DISTINCT PRODUCT_KEY) AS TOTAL_PRODUCTS,
			MIN(ORDER_DATE) AS FIRST_ORDER_DATE,
			MAX(ORDER_DATE) AS LAST_ORDER_DATE,
			EXTRACT(
				YEAR
				FROM
					AGE (MAX(ORDER_DATE), MIN(ORDER_DATE))
			) * 12 + EXTRACT(
				MONTH
				FROM
					AGE (MAX(ORDER_DATE), MIN(ORDER_DATE))
			) AS LIFE_SPAN
		FROM
			BASE_QUERY
		GROUP BY
			CUSTOMER_KEY,
			CUSTOMER_NAME,
			CUSTOMER_NUMBER,
			AGE
	)
SELECT
	CUSTOMER_KEY,
	CUSTOMER_NUMBER,
	CUSTOMER_NAME,
	CONCAT(AGE, ' ', 'Year') AS AGE,
	CASE
		WHEN AGE < 20 THEN 'Under 20'
		WHEN AGE BETWEEN 20 AND 29  THEN '20-29'
		WHEN AGE BETWEEN 30 AND 39  THEN '30-39'
		WHEN AGE BETWEEN 40 AND 49  THEN '40-49'
		ELSE '50 and Above'
	END AS AGE_GROUP,
	CASE
		WHEN LIFE_SPAN >= 12
		AND TOTAL_SALES > 5000 THEN 'VIP'
		WHEN LIFE_SPAN >= 12
		AND TOTAL_SALES <= 5000 THEN 'Reqular'
		ELSE 'New'
	END AS CUSTOMER_SEGMENT,
	FIRST_ORDER_DATE,
	LAST_ORDER_DATE,
	CONCAT(LIFE_SPAN, ' ', 'Month') AS LIFE_SPAN,
	CONCAT(
		EXTRACT(
			YEAR
			FROM
				AGE (LAST_ORDER_DATE)
		) * 12 + EXTRACT(
			MONTH
			FROM
				AGE (LAST_ORDER_DATE)
		),
		' ',
		'Month'
	) AS RECENCY,
	-- compute average monthly spend
	CASE
		WHEN LIFE_SPAN = 0 THEN TOTAL_SALES
		ELSE ROUND(TOTAL_SALES / LIFE_SPAN)
	END AS AVG_MONTHLY_SPEND,
	TOTAL_ORDERS,
	TOTAL_SALES,
	TOTAL_QUANTITY,
	TOTAL_PRODUCTS,
	-- compute average order value (AVO)
	CASE
		WHEN TOTAL_SALES = 0 THEN 0
		ELSE TOTAL_SALES / TOTAL_ORDERS
	END AS AVG_ORDER_VALUE
FROM
	CUSTOMER_AGG;

SELECT
	*
FROM
	REPORT_CUSTOMERS;