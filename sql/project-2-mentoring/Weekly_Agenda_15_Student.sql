---- RDB&SQL Exercise-2 Student

----1. By using view get the average sales by staffs and years using the AVG() aggregate function.
CREATE OR ALTER VIEW v_avg_sales
AS
SELECT staff_id, YEAR(order_date) year, AVG(list_price * quantity *(1-discount)) avg_sale
FROM sale.order_item AS OI
LEFT JOIN sale.orders AS O
ON O.order_id = OI.order_id
GROUP BY staff_id, YEAR(order_date);

-- get results
SELECT *
FROM v_avg_sales
ORDER BY staff_id

----2. Select the annual amount of product produced according to brands (use window functions).
--first looks
SELECT *
FROM product.product

SELECT *
FROM product.stock

-- group by cozumu
SELECT B.brand_name, model_year, SUM(quantity) quantity
FROM product.product P
LEFT JOIN product.stock S
ON P.product_id = S.product_id
LEFT JOIN product.brand AS B
ON P.brand_id = B.brand_id
GROUP BY B.brand_name, model_year
ORDER BY B.brand_name, model_year;

-- window function cozumu
WITH product_stock AS (
SELECT DISTINCT B.brand_name, P.model_year, SUM(S.quantity) OVER (PARTITION BY B.brand_name, P.model_year) quantity
FROM product.product P
LEFT JOIN product.stock S
ON P.product_id = S.product_id
LEFT JOIN product.brand AS B
ON P.brand_id = B.brand_id
)
SELECT brand_name, model_year, quantity
FROM product_stock
ORDER BY brand_name, model_year;

-- yukaridaki ile ayni
SELECT DISTINCT B.brand_name, P.model_year, SUM(S.quantity) OVER (PARTITION BY B.brand_name, P.model_year) quantity
FROM product.product P
LEFT JOIN product.stock S
ON P.product_id = S.product_id
LEFT JOIN product.brand AS B
ON P.brand_id = B.brand_id

----3. Select the least 3 products in stock according to stores.
-- first looks
SELECT *
FROM sale.store

SELECT *
FROM product.stock

SELECT *
FROM product.stock
WHERE quantity > 0
ORDER BY quantity ASC

-- add row number to stores stocks according to store_id ordered by quantity
WITH CTE AS (
    SELECT store_id, product_id, quantity, ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY quantity ASC) AS RowNum
    FROM product.stock
    WHERE quantity > 0
)
SELECT store_id, product_id, quantity, RowNum
FROM CTE

-- just select 3 least stocks from stores
WITH CTE AS (
    SELECT store_id, product_id, quantity, ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY quantity ASC) AS RowNum
    FROM product.stock
    WHERE quantity > 0
)
SELECT store_id, product_id, quantity
FROM CTE
WHERE RowNum <= 3
ORDER BY store_id, RowNum


----4. Return the average number of sales orders in 2020 sales

-- First calculate total quantity of orders
SELECT A.order_id, SUM(quantity) total_quantity
FROM sale.order_item AS A
LEFT JOIN sale.orders AS B
ON A.order_id = B.order_id
WHERE YEAR(order_date) = 2020
GROUP BY A.order_id
ORDER BY A.order_id

-- Then calculate its average
WITH CTE AS (
    SELECT A.order_id, SUM(quantity) total_quantity
    FROM sale.order_item AS A
    LEFT JOIN sale.orders AS B
    ON A.order_id = B.order_id
    WHERE YEAR(order_date) = 2020
    GROUP BY A.order_id
)
SELECT 2020 AS year, AVG(total_quantity) avg_total_quantity
FROM CTE

-- Look at all the years
WITH CTE AS (
    SELECT A.order_id, YEAR(order_date) order_year, SUM(quantity) total_quantity
    FROM sale.order_item AS A
    LEFT JOIN sale.orders AS B
    ON A.order_id = B.order_id
    GROUP BY A.order_id, YEAR(order_date)
)
SELECT order_year, AVG(CAST(total_quantity AS FLOAT)) avg_total_quantity
FROM CTE
GROUP BY order_year;

----5. Assign a rank to each product by list price in each brand and get products with rank less than or equal to three.
SELECT *
FROM product.product

-- look at all the ranks
WITH ranked_products AS (
    SELECT brand_id, product_name, list_price, RANK() OVER (PARTITION BY brand_id ORDER BY list_price) AS rank
    FROM product.product
)
SELECT brand_id, product_name, list_price, rank
FROM ranked_products

-- ranks equal or below three
WITH ranked_products AS (
    SELECT brand_id, product_name, list_price, RANK() OVER (PARTITION BY brand_id ORDER BY list_price) AS rank
    FROM product.product
)
SELECT brand_id, product_name, list_price, rank
FROM ranked_products
WHERE rank <= 3;