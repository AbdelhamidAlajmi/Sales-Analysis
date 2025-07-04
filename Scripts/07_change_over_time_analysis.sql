-- Changes Over Time Analysis
-- By Year
SELECT
	EXTRACT(
		YEAR
		FROM
			ORDER_DATE
	) AS ORDER_YEAR,
	SUM(SALES_AMOUNT) AS TOTAL_SALES,
	COUNT(DISTINCT CUSTOMER_KEY) AS TOTAL_CUSTOMERS,
	SUM(QUANTITY) AS TOTAL_QUANTITY
FROM
	FACT_SALES
WHERE
	ORDER_DATE IS NOT NULL
GROUP BY
	EXTRACT(
		YEAR
		FROM
			ORDER_DATE
	)
ORDER BY
	EXTRACT(
		YEAR
		FROM
			ORDER_DATE
	);

-----------------------------------------------------------
-- By Month
SELECT
	DATE (DATE_TRUNC('month', ORDER_DATE)) AS ORDER_DATE,
	SUM(SALES_AMOUNT) AS TOTAL_SALES,
	COUNT(DISTINCT CUSTOMER_KEY) AS TOTAL_CUSTOMERS,
	SUM(QUANTITY) AS TOTAL_QUANTITY
FROM
	FACT_SALES
WHERE
	ORDER_DATE IS NOT NULL
GROUP BY
	DATE (DATE_TRUNC('month', ORDER_DATE))
ORDER BY
	DATE (DATE_TRUNC('month', ORDER_DATE));
