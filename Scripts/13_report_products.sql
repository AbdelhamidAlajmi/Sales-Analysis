-- -- Build Product Report
/*
===============================================================================
Product Report
===============================================================================
Purpose:
- This report consolidates key product metrics and behaviors.

Highlights:
1. Gathers essential fields such as product name, category, subcategory, and cost.
2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
3. Aggregates product-level metrics:
- total orders
- total sales
- total quantity sold
- total customers (unique)
- lifespan (in months)
4. Calculates valuable KPIs:
- recency (months since last sale)
- average order revenue (AOR)
- average monthly revenue
===============================================================================
*/
-- =============================================================================
-- Create Report: gold.report_products
CREATE VIEW PRODUCT_VIEW AS
-- =============================================================================
WITH
	BASE_QUERY AS (
		SELECT
			S.ORDER_NUMBER,
			S.ORDER_DATE,
			S.CUSTOMER_KEY,
			S.SALES_AMOUNT,
			S.QUANTITY,
			S.PRODUCT_KEY,
			P.PRODUCT_NAME,
			P.CATEGORY,
			P.SUBCATEGORY,
			P.COST
		FROM
			FACT_SALES S
			JOIN DIM_PRODUCTS P ON S.PRODUCT_KEY = P.PRODUCT_KEY
		WHERE
			ORDER_DATE IS NOT NULL
	),
	PROD_AGG AS (
		SELECT
			PRODUCT_KEY,
			PRODUCT_NAME,
			CATEGORY,
			SUBCATEGORY,
			COST,
			COUNT(DISTINCT ORDER_NUMBER) AS TOTAL_ORDERS,
			SUM(SALES_AMOUNT) AS TOTAL_SALES,
			SUM(QUANTITY) AS TOTAL_QUANTITY_SOLD,
			COUNT(DISTINCT CUSTOMER_KEY) AS TOTAL_CUSTOMERS,
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
			) AS LIFE_SPAN,
			ROUND(
				AVG(SALES_AMOUNT::NUMERIC / NULLIF(QUANTITY, 0)),
				2
			) AS AVG_SELLING_PRICE
		FROM
			BASE_QUERY
		GROUP BY
			PRODUCT_KEY,
			PRODUCT_NAME,
			CATEGORY,
			SUBCATEGORY,
			COST
	)
SELECT
	PRODUCT_KEY,
	PRODUCT_NAME,
	CATEGORY,
	SUBCATEGORY,
	COST,
	LAST_ORDER_DATE,
	EXTRACT(
		YEAR
		FROM
			AGE (CURRENT_DATE, LAST_ORDER_DATE)
	) * 12 + EXTRACT(
		MONTH
		FROM
			AGE (CURRENT_DATE, LAST_ORDER_DATE)
	) AS RECENCY_IN_MONTHS,
	CASE
		WHEN TOTAL_SALES > 50000 THEN 'High_Performer'
		WHEN TOTAL_SALES >= 10000 THEN 'Mid-Performer'
		ELSE 'Low-Performer'
	END AS PRODUCT_SEGMENT,
	LIFE_SPAN,
	TOTAL_ORDERS,
	TOTAL_SALES,
	TOTAL_QUANTITY_SOLD,
	TOTAL_CUSTOMERS,
	AVG_SELLING_PRICE,
	-- Average Order Revenue (AOR)
	CASE
		WHEN TOTAL_ORDERS = 0 THEN 0
		ELSE TOTAL_SALES / TOTAL_ORDERS
	END AS AVG_ORDER_REVENUE,
	-- average montly revenue
	CASE
		WHEN LIFE_SPAN = 0 THEN 0
		ELSE ROUND(TOTAL_SALES / LIFE_SPAN)
	END AS AVG_MONTLY_REVENUE
FROM
	PROD_AGG;

SELECT
	*
FROM
	PRODUCT_VIEW;