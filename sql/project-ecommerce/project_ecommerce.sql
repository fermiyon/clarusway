SELECT *
FROM sales

SELECT Cust_ID
FROM sales
GROUP BY Cust_ID
ORDER BY 1

SELECT CUST_ID, CAST(SUBSTRING(Cust_ID, PATINDEX('%[0-9]%', Cust_ID), LEN(Cust_ID)) AS INT) Cust_ID2
FROM sales
GROUP BY Cust_ID
ORDER BY 2

SELECT DISTINCT Ord_ID
FROM sales
WHERE Cust_ID = 'Cust_1140'

-- 1. Find the top 3 customers who have the maximum count of orders.
SELECT TOP 3 Cust_ID, COUNT(DISTINCT Ord_ID) total_order
FROM sales
GROUP BY Cust_ID
ORDER BY 2 DESC

-- 2. Find the customer whose order took the maximum time to get shipping.
SELECT TOP 1 Cust_ID
FROM sales
ORDER BY DaysTakenForShipping DESC

-- 3. Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011
-- First look
SELECT DISTINCT Cust_ID
FROM sales
WHERE YEAR(Order_Date) = 2011 AND MONTH(Order_Date) = 1

-- solution
;WITH months AS
(
    SELECT 'January' AS Month UNION ALL
    SELECT 'February' UNION ALL
    SELECT 'March' UNION ALL
    SELECT 'April' UNION ALL
    SELECT 'May' UNION ALL
    SELECT 'June' UNION ALL
    SELECT 'July' UNION ALL
    SELECT 'August' UNION ALL
    SELECT 'September' UNION ALL
    SELECT 'October' UNION ALL
    SELECT 'November' UNION ALL
    SELECT 'December'
)
SELECT Month, 
    (
    SELECT COUNT(DISTINCT Cust_ID) 
    FROM
        (
        SELECT DISTINCT Cust_ID
        FROM sales A
        WHERE YEAR(Order_Date) = 2011 AND MONTH(Order_Date) = 1
        INTERSECT
        SELECT DISTINCT Cust_ID
        FROM sales B
        WHERE YEAR(Order_Date) = 2011 AND MONTH(Order_Date) = (DATEPART(MONTH, CONVERT(DATETIME, '1' + M.Month + '2023')))
        ) came_back_customers
    ) AS came_back_customers_count
FROM months M


--4. Write a query to return for each user the time elapsed between the 
-- first purchasing and the third purchasing, in ascending order by Customer ID.

-- FIRST LOOK
SELECT *
FROM sales

-- ordering by customer id by their numeric part
SELECT *
FROM sales
ORDER BY CAST(SUBSTRING(Cust_ID, PATINDEX('%[0-9]%', Cust_ID), LEN(Cust_ID)) AS INT)

SELECT COUNT(DISTINCT Ord_ID)
FROM sales

SELECT COUNT(DISTINCT Ship_ID)
FROM sales

SELECT COUNT(DISTINCT Cust_ID)
FROM sales

-- control
;WITH CTE AS (
    SELECT Ord_ID, Ship_ID, DaysTakenForShipping
    FROM sales
    GROUP BY Ord_ID, Ship_ID, DaysTakenForShipping
    --ORDER BY Ord_ID
)
SELECT Ship_ID
FROM CTE
GROUP BY Ship_ID
HAVING COUNT(Ship_ID) > 1

-- order id farkli ship id ayni durum var
SELECT *
FROM sales
WHERE Ship_ID = 'SHP_7163'

-- customers order ranks
SELECT 
    Ord_ID, Cust_ID, Order_Date,
    ROW_NUMBER() OVER (PARTITION BY Cust_ID ORDER BY Order_Date ASC) order_rank
FROM sales
GROUP BY Ord_ID, Cust_ID, Order_Date
ORDER BY CAST(SUBSTRING(Cust_ID, PATINDEX('%[0-9]%', Cust_ID), LEN(Cust_ID)) AS INT)

-- First solution
-- First enumerating the customers order by order date with CTE
-- Second selecting customers who has three or more orders and calculate the time elapsed between them
-- Third selecting customer who has below three orders
-- Union them
-- Ordering by Customer ID by their numeric values

;WITH CTE AS(
    SELECT 
        Ord_ID, Cust_ID, Order_Date,
        ROW_NUMBER() OVER (PARTITION BY Cust_ID ORDER BY Order_Date ASC) order_rank
    FROM sales
    GROUP BY Ord_ID, Cust_ID, Order_Date
    --ORDER BY CAST(SUBSTRING(Cust_ID, PATINDEX('%[0-9]%', Cust_ID), LEN(Cust_ID)) AS INT)
)
SELECT * FROM
(SELECT 
    Cust_ID,
    CAST(
        DATEDIFF(
            DAY,
            (SELECT Order_Date FROM CTE cte2 WHERE cte2.Cust_ID = cte.Cust_ID AND order_rank = 1),
            (SELECT Order_Date FROM CTE cte2 WHERE cte2.Cust_ID = cte.Cust_ID AND order_rank = 3)
        ) 
     AS VARCHAR) time_elapsed
FROM CTE cte
GROUP BY Cust_ID
HAVING COUNT(Ord_ID) >= 3
UNION
SELECT 
    Cust_ID, 'below three orders' time_elapsed
FROM CTE cte
GROUP BY Cust_ID
HAVING COUNT(Ord_ID) < 3) t
ORDER BY CAST(SUBSTRING(Cust_ID, PATINDEX('%[0-9]%', Cust_ID), LEN(Cust_ID)) AS INT)


-- 5. Write a query that returns customers who purchased both product 11 
-- and product 14, as well as the ratio of these products to the total number of products purchased by the customer.

-- Control
SELECT * FROM sales
ORDER BY CAST(SUBSTRING(Cust_ID, PATINDEX('%[0-9]%', Cust_ID), LEN(Cust_ID)) AS INT)

-- Solution
-- Customers who Purchased Prod 11
;WITH CTE AS (
    SELECT Cust_ID
    FROM sales
    WHERE Prod_ID = 'Prod_11'
    GROUP BY Cust_ID
)
-- Customers who Purchased Prod 14
, CTE2 AS (
    SELECT Cust_ID
    FROM sales
    WHERE Prod_ID = 'Prod_14'
    GROUP BY Cust_ID
)
-- Customers who Purchased Prod 11 and Prod 14
, CTE3 AS (
    SELECT * FROM CTE
    INTERSECT
    SELECT * FROM CTE2
) --SELECT * FROM CTE3 ORDER BY CAST(SUBSTRING(Cust_ID, PATINDEX('%[0-9]%', Cust_ID), LEN(Cust_ID)) AS INT)
-- Customers total_order_quantity
, CTE4 AS (
    SELECT Cust_ID, COUNT(Prod_ID) total_number_of_products, SUM(Order_Quantity) total_order_quantity
    FROM sales
    GROUP BY Cust_ID
    --ORDER BY CAST(SUBSTRING(Cust_ID, PATINDEX('%[0-9]%', Cust_ID), LEN(Cust_ID)) AS INT)
)
-- Customers who Purchased Prod 11 and Prod 14, total_order_quantity 
, CTE5 AS (
    SELECT A.Cust_ID, total_order_quantity
    FROM CTE3 A
    JOIN CTE4 B ON A.Cust_ID = B.Cust_ID
)
-- Customers who Purchased Prod 11 and Prod 14, total quantity of Prod 11 and Prod 14
, CTE6 AS (
    SELECT Cust_ID, SUM(Order_Quantity) total_quantity_14_and_11
    FROM sales
    WHERE Prod_ID = 'Prod_14' OR Prod_ID = 'Prod_11'
    GROUP BY Cust_ID
    HAVING COUNT(DISTINCT Prod_ID) = 2
    --ORDER BY CAST(SUBSTRING(Cust_ID, PATINDEX('%[0-9]%', Cust_ID), LEN(Cust_ID)) AS INT)
)
-- ratio
, CTE7 AS (
    SELECT A.Cust_ID, CAST((total_quantity_14_and_11*1.0) / total_order_quantity AS DECIMAL(18,2)) ratio
    FROM CTE6 A
    JOIN CTE5 B ON A.Cust_ID = B.Cust_ID
)
SELECT * FROM CTE7
ORDER BY CAST(SUBSTRING(Cust_ID, PATINDEX('%[0-9]%', Cust_ID), LEN(Cust_ID)) AS INT)

-- CUSTOMER SEGMENTATION

-- 1- Create a “view” that keeps visit logs of customers on a monthly basis. 
-- (For each log, three field is kept: Cust_id, Year, Month)
CREATE OR ALTER VIEW log AS (
    SELECT Cust_ID, YEAR(Order_Date) Year, MONTH(Order_Date) Month, DATENAME(MONTH,Order_Date) month_name
    FROM sales
    GROUP BY Ord_ID, Cust_ID, Order_Date
)
CREATE OR ALTER VIEW log_distinct AS (
    SELECT DISTINCT Cust_ID, YEAR(Order_Date) Year, MONTH(Order_Date) Month
    FROM sales
)

SELECT * FROM log
ORDER BY CAST(SUBSTRING(Cust_ID, PATINDEX('%[0-9]%', Cust_ID), LEN(Cust_ID)) AS INT)

-- 2. Create a “view” that keeps the number of monthly visits by users. (Show separately all months from the beginning business)

SELECT MIN(Order_Date)
FROM sales

SELECT MAX(Order_Date)
FROM sales

;WITH months AS
(
    SELECT 'January' AS Month UNION ALL
    SELECT 'February' UNION ALL
    SELECT 'March' UNION ALL
    SELECT 'April' UNION ALL
    SELECT 'May' UNION ALL
    SELECT 'June' UNION ALL
    SELECT 'July' UNION ALL
    SELECT 'August' UNION ALL
    SELECT 'September' UNION ALL
    SELECT 'October' UNION ALL
    SELECT 'November' UNION ALL
    SELECT 'December'
), years AS (
    SELECT 2009 AS Year UNION ALL
    SELECT 2010 UNION ALL
    SELECT 2011 UNION ALL
    SELECT 2012
), dates AS (
    SELECT * FROM months
    CROSS JOIN years
) --SELECT * FROM dates
SELECT *,
    (SELECT COUNT(Cust_ID) FROM log_distinct WHERE [Year] = A.[Year] AND [Month] = (DATEPART(MONTH, CONVERT(DATETIME, '1' + A.[Month] + '2023'))) ) distinct_visits,
    (SELECT COUNT(Cust_ID) FROM log WHERE [Year] = A.[Year] AND [Month] = (DATEPART(MONTH, CONVERT(DATETIME, '1' + A.[Month] + '2023'))) ) total_visits
FROM dates A

CREATE OR ALTER VIEW visits AS
    WITH months AS
    (
        SELECT 'January' AS Month UNION ALL
        SELECT 'February' UNION ALL
        SELECT 'March' UNION ALL
        SELECT 'April' UNION ALL
        SELECT 'May' UNION ALL
        SELECT 'June' UNION ALL
        SELECT 'July' UNION ALL
        SELECT 'August' UNION ALL
        SELECT 'September' UNION ALL
        SELECT 'October' UNION ALL
        SELECT 'November' UNION ALL
        SELECT 'December'
    ), years AS (
        SELECT 2009 AS Year UNION ALL
        SELECT 2010 UNION ALL
        SELECT 2011 UNION ALL
        SELECT 2012
    ), dates AS (
        SELECT * FROM months
        CROSS JOIN years
    ) --SELECT * FROM dates
    SELECT *,
        (SELECT COUNT(Cust_ID) FROM log_distinct WHERE [Year] = A.[Year] AND [Month] = (DATEPART(MONTH, CONVERT(DATETIME, '1' + A.[Month] + '2023'))) ) distinct_visits,
        (SELECT COUNT(Cust_ID) FROM log WHERE [Year] = A.[Year] AND [Month] = (DATEPART(MONTH, CONVERT(DATETIME, '1' + A.[Month] + '2023'))) ) total_visits,
        ROW_NUMBER() OVER(ORDER BY (SELECT 1)) row_num
    FROM dates A


-- 3. For each visit of customers, create the next month of the visit as a separate column
-- 4. Calculate the monthly time gap between two consecutive visits by each customer.
;WITH CTE AS (
    SELECT 
        Cust_ID, Order_Date,
        LEAD(Order_Date) OVER (PARTITION BY Cust_ID ORDER BY Order_Date) next_visit
    FROM sales
    GROUP BY Ord_ID, Cust_ID, Order_Date
)
SELECT
    *,
    DATEDIFF(MONTH, Order_Date, next_visit) gap
FROM CTE

-- 5. Categorise customers using average time gaps. Choose the most fitted labeling model for you.
-- For example:
-- o Labeled as churn if the customer hasn't made another purchase in the months since they made their first purchase.
-- o Labeled as regular if the customer has made a purchase every month. Etc.

-- First look monthly churn by orders
;WITH CTE AS (
    SELECT 
        Cust_ID, Order_Date,
        LEAD(Order_Date) OVER (PARTITION BY Cust_ID ORDER BY Order_Date) next_visit
    FROM sales
    GROUP BY Ord_ID, Cust_ID, Order_Date
), CTE2 AS (
    SELECT
        *,
        DATEDIFF(MONTH, Order_Date, next_visit) gap
    FROM CTE
), CTE3 AS (
    SELECT 
        *, 
        CASE WHEN gap <=1 THEN 'regular' ELSE 'churn' END AS monthly_churn
    FROM CTE2
    WHERE gap IS NOT NULL
)
SELECT
    *
FROM CTE3

-- Second look by average churn

;WITH CTE AS (
    SELECT 
        Cust_ID, Order_Date,
        LEAD(Order_Date) OVER (PARTITION BY Cust_ID ORDER BY Order_Date) next_visit
    FROM sales
    GROUP BY Ord_ID, Cust_ID, Order_Date
), CTE2 AS (
    SELECT
        *,
        DATEDIFF(MONTH, Order_Date, next_visit) gap
    FROM CTE
), CTE3 AS (
    SELECT 
        *, 
        AVG(gap*1.0) OVER () avg_gap,
        AVG(gap*1.0) OVER (PARTITION BY Cust_ID) avg_customer
    FROM CTE2
    WHERE gap IS NOT NULL
), CTE4 AS (
    SELECT
        DISTINCT
        Cust_ID,
        CASE WHEN avg_customer < avg_gap THEN 'regular' ELSE 'churn' END AS churn_by_avg
    FROM CTE3
), CTE5 AS (
    SELECT *, 'not enough data' churn_by_avg
    FROM
    (SELECT DISTINCT Cust_ID
    FROM sales
    EXCEPT
    SELECT Cust_ID
    FROM CTE4) t
)
SELECT * FROM
    (SELECT * FROM CTE4
    UNION
    SELECT * FROM CTE5) t
ORDER BY CAST(SUBSTRING(Cust_ID, PATINDEX('%[0-9]%', Cust_ID), LEN(Cust_ID)) AS INT)

-- Month-Wise Retention Rate
-- Find month-by-month customer retention ratei since the start of the business.
-- There are many different variations in the calculation of Retention Rate. But we will try to calculate the month-wise retention rate in this project.
-- So, we will be interested in how many of the customers in the previous month could be retained in the next month.
-- Proceed step by step by creating “views”. You can use the view you got at the end of the Customer Segmentation section as a source.
-- 1. Find the number of customers retained month-wise. (You can use time gaps) 2. Calculatethemonth-wiseretentionrate.
-- Month-Wise Retention Rate = 1.0 * Number of Customers Retained in The Current Month / Total Number of Customers in the Current Month
-- If you want, you can track your own way.

SELECT *
FROM log

SELECT *
FROM visits

SELECT DISTINCT Cust_ID
FROM [log]
WHERE [Year] = 2012 And [Month] = 7
INTERSECT
SELECT DISTINCT Cust_ID
FROM [log]
WHERE [Year] = 2012 And [Month] = 8

-- MONTH-WISE RETENTION RATE
;WITH CTE AS (
    SELECT 
        *,
        LAG([Month]) OVER(ORDER BY row_num) previous_month,
        LAG([Year]) OVER(ORDER BY row_num) previous_year_column
    FROM visits
), CTE2 AS (
    SELECT [Month], [Year], distinct_visits,
        (SELECT COUNT(Cust_ID) FROM
        (
            SELECT DISTINCT Cust_ID
            FROM [log]
            WHERE [Year] = V.previous_year_column And [month_name] = V.previous_month
            INTERSECT
            SELECT DISTINCT Cust_ID
            FROM [log]
            WHERE [Year] = V.[Year] And [month_name] = V.[Month]
        )t) retention
    FROM CTE V
), CTE3 AS (
    SELECT
        *,
        CAST(1.0 * retention /distinct_visits AS DECIMAL(18,2)) retention_rate
    FROM CTE2
)
SELECT * FROM CTE3
