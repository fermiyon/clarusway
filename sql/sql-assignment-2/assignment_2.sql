-- In this assignment two different missions waiting for you.

-- 1. Product Sales
-- You need to create a report on whether customers who purchased the product named '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD' buy the product below or not.
-- 'Polk Audio - 50 W Woofer - Black' -- (other_product)
-- To generate this report, you are required to use the appropriate SQL Server Built-in functions or expressions as well as basic SQL knowledge.

SELECT *
FROM sale.order_item A, product.product B
WHERE A.product_id = B.product_id -- join
AND product_name = '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD'

SELECT *
FROM sale.order_item A, product.product B
WHERE A.product_id = B.product_id -- join
AND product_name = 'Polk Audio - 50 W Woofer - Black'

SELECT C.customer_id, first_name, last_name
FROM sale.order_item A, product.product B, sale.orders C, sale.customer D
WHERE A.product_id = B.product_id -- join
AND C.order_id = A.order_id -- join
AND C.customer_id = D.customer_id --join
AND product_name = '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD'

SELECT C.customer_id, first_name, last_name
FROM sale.order_item A, product.product B, sale.orders C, sale.customer D
WHERE A.product_id = B.product_id -- join
AND C.order_id = A.order_id -- join
AND C.customer_id = D.customer_id --join
AND product_name = 'Polk Audio - 50 W Woofer - Black'

-- First answer
WITH CTE AS (
    SELECT DISTINCT C.customer_id, first_name, last_name
    FROM sale.order_item A, product.product B, sale.orders C, sale.customer D
    WHERE A.product_id = B.product_id -- join
    AND C.order_id = A.order_id -- join
    AND C.customer_id = D.customer_id --join
    AND product_name = '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD'
), CTE2 AS (
    SELECT DISTINCT C.customer_id, first_name, last_name
    FROM sale.order_item A, product.product B, sale.orders C, sale.customer D
    WHERE A.product_id = B.product_id -- join
    AND C.order_id = A.order_id -- join
    AND C.customer_id = D.customer_id --join
    AND product_name = 'Polk Audio - 50 W Woofer - Black'
), CTE3 AS (
    SELECT * FROM CTE
    EXCEPT
    SELECT * FROM CTE2
), CTE4 AS (
    SELECT * FROM CTE
    INTERSECT
    SELECT * FROM CTE2
)
SELECT *, 'No' other_brand
FROM CTE3 cte3
UNION ALL
SELECT *, 'Yes' other_brand
FROM CTE4 cte4
ORDER BY customer_id


-- Second answer
SELECT DISTINCT C.customer_id, first_name, last_name,
       (CASE WHEN EXISTS (SELECT 1 FROM sale.order_item A2, product.product B2, sale.orders C2
                          WHERE A2.product_id = B2.product_id
                          AND C2.order_id = A2.order_id
                          AND B2.product_name = 'Polk Audio - 50 W Woofer - Black'
                          AND C2.customer_id = C.customer_id) THEN 'Yes' ELSE 'No' END) AS 'other_brand'
FROM sale.order_item A, product.product B, sale.orders C, sale.customer D
WHERE A.product_id = B.product_id
AND B.product_name = '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD'
AND C.order_id = A.order_id
AND C.customer_id = D.customer_id

--Third answer
WITH cte AS (
    SELECT DISTINCT C.customer_id, first_name, last_name, product_name
    FROM sale.order_item A
    JOIN product.product B ON A.product_id = B.product_id
    JOIN sale.orders C ON C.order_id = A.order_id
    JOIN sale.customer D ON C.customer_id = D.customer_id
)
SELECT customer_id, first_name, last_name,
       (CASE WHEN EXISTS (SELECT 1 FROM CTE cte2
                          WHERE cte2.product_name = 'Polk Audio - 50 W Woofer - Black'
                          AND cte2.customer_id = cte.customer_id) THEN 'Yes' ELSE 'No' END) AS 'other_brand'
FROM cte
WHERE product_name = '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD'
ORDER BY customer_id

-- 2. Conversion Rate
-- Below you see a table of the actions of customers visiting the website by clicking on two different types of advertisements given by an E-Commerce company. Write a query to return the conversion rate for each Advertisement type.


-- a.    Create above table (Actions) and insert values,
CREATE TABLE ECommerce (	Visitor_ID INT IDENTITY (1, 1) PRIMARY KEY,	Adv_Type VARCHAR (255) NOT NULL,	Action1 VARCHAR (255) NOT NULL);
INSERT INTO ECommerce (Adv_Type, Action1)VALUES ('A', 'Left'),('A', 'Order'),('B', 'Left'),('A', 'Order'),('A', 'Review'),('A', 'Left'),('B', 'Left'),('B', 'Order'),('B', 'Review'),('A', 'Review');
 
SELECT *
FROM dbo.ECommerce
-- b.    Retrieve count of total Actions and Orders for each Advertisement Type,
SELECT DISTINCT Adv_Type, Action1, COUNT(Action1) OVER (PARTITION BY Adv_Type, Action1)
FROM dbo.ECommerce
ORDER BY Adv_Type

SELECT Adv_Type, Action1, COUNT(Action1)
FROM dbo.ECommerce
GROUP BY Adv_Type, Action1
ORDER BY Adv_Type

SELECT Adv_Type, COUNT(Action1) total_actions, (SELECT COUNT(Action1) FROM dbo.ECommerce WHERE Action1 = 'Order' AND Adv_Type = E.Adv_Type) total_orders
FROM dbo.ECommerce E
GROUP BY Adv_Type

-- First answer
SELECT Adv_Type, 
       COUNT(CASE WHEN Action1 = 'Order' THEN 1 END) AS Orders, 
       COUNT(CASE WHEN Action1 = 'Review' THEN 1 END) AS Reviews, 
       COUNT(CASE WHEN Action1 = 'Left' THEN 1 END) AS Lefts,
       COUNT(*) AS Total_Action
FROM ECommerce 
GROUP BY Adv_Type

-- Second answer
SELECT *, [Order]+[Review]+[Left] as Total_Action
FROM (SELECT Adv_Type,Action1 FROM ECommerce) as subquery
PIVOT (COUNT(Action1) FOR Action1 IN ([Order], [Review], [Left])) pvt
 

-- c.    Calculate Orders (Conversion) rates for each Advertisement Type by dividing by total count of actions casting as float by multiplying by 1.0.
-- First
SELECT Adv_Type,
       CAST(COUNT(CASE WHEN Action1 = 'Order' THEN 1 END) * 1.0 / COUNT(*) * 1.0 AS DECIMAL(18,2)) Conversion_Rate
FROM ECommerce
GROUP BY Adv_Type

-- Second
SELECT Adv_Type, CAST([Order] * 1.0 / ([Order]+[Review]+[Left]) *1.0 AS DECIMAL(18,2)) as Conversion_Rate
FROM (SELECT Adv_Type,Action1 FROM ECommerce) as subquery
PIVOT (COUNT(Action1) FOR Action1 IN ([Order], [Review], [Left])) pvt

-- Third

SELECT Adv_Type, 
       CAST((SELECT COUNT(Action1) * 1.0 FROM dbo.ECommerce WHERE Action1 = 'Order' AND Adv_Type = E.Adv_Type) / COUNT(Action1) * 1.0 as DECIMAL(18,2))  Conversion_rate
FROM dbo.ECommerce E
GROUP BY Adv_Type