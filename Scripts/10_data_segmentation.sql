-- Data Segmentation
--Products Count by Cost Range
WITH
	PRODUCT_SEGMENTS AS (
		SELECT
			PRODUCT_KEY,
			PRODUCT_NAME,
			COST,
			CASE
				WHEN COST < 100 THEN 'Below 100'
				WHEN COST BETWEEN 100 AND 500  THEN '100-500'
				WHEN COST BETWEEN 500 AND 1000  THEN '500-1000'
				ELSE 'Above 1000'
			END COST_RANGE
		FROM
			DIM_PRODUCTS
		ORDER BY
			COST DESC
	)
SELECT
	COST_RANGE,
	COUNT(PRODUCT_KEY) AS TOTAL_PRODUCTS
FROM
	PRODUCT_SEGMENTS
GROUP BY
	COST_RANGE
ORDER BY
	TOTAL_PRODUCTS DESC;

-- Customers Spending Behavior
WITH
	CUST_SEGM AS (
		SELECT
			S.CUSTOMER_KEY,
			EXTRACT(
				YEAR
				FROM
					AGE (MAX(ORDER_DATE), MIN(ORDER_DATE))
			) * 12 + EXTRACT(
				MONTH
				FROM
					AGE (MAX(ORDER_DATE), MIN(ORDER_DATE))
			) AS NUM_MONTHS,
			SUM(S.SALES_AMOUNT) AS TOTAL_SALES
		FROM
			FACT_SALES S
			JOIN DIM_CUSTOMERS C ON S.CUSTOMER_KEY = C.CUSTOMER_KEY
		GROUP BY
			S.CUSTOMER_KEY
		ORDER BY
			NUM_MONTHS DESC
	),
	CLASSIFY AS (
		SELECT
			*,
			CASE
				WHEN NUM_MONTHS >= 12
				AND TOTAL_SALES > 5000 THEN 'VIP'
				WHEN NUM_MONTHS >= 12
				AND TOTAL_SALES <= 5000 THEN 'Regular'
				ELSE 'New'
			END AS CUSTOMER_CLASS
		FROM
			CUST_SEGM
		WHERE
			NUM_MONTHS IS NOT NULL
	)
SELECT
	CUSTOMER_CLASS,
	COUNT(CUSTOMER_KEY) AS NUMBER_OF_CUSTOMERS
FROM
	CLASSIFY
GROUP BY
	CUSTOMER_CLASS
ORDER BY
	NUMBER_OF_CUSTOMERS DESC;
