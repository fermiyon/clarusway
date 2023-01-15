
---- 1. List all the cities in the Texas and the numbers of customers in each city.----
SELECT city, COUNT(customer_id) as number_of_customer 
FROM SampleRetail.sale.customer
WHERE state = 'TX'
GROUP BY city 

---- 2. List all the cities in the California which has more than 5 customer, by showing the cities which have more customers first.---
SELECT city, COUNT(customer_id) AS number_of_customer 
FROM SampleRetail.sale.customer
WHERE state = 'CA'
GROUP BY city
HAVING COUNT(customer_id) > 5
ORDER BY number_of_customer DESC;

---- 3. List the top 10 most expensive products----
SELECT TOP 10 product_name, list_price
FROM SampleRetail.product.product
ORDER BY list_price DESC;


---- 4. List store_id, product name and list price and the quantity of the products which are located in the store id 2 and the quantity is greater than 25----
SELECT 
    store_id, 
    product_name, 
    list_price, 
    quantity 
FROM 
    SampleRetail.product.stock AS S
JOIN SampleRetail.product.product AS P
ON S.product_id = P.product_id
WHERE store_id = 2 AND quantity > 25

---- 5. Find the sales order of the customers who lives in Boulder order by order date----
SELECT 
    order_id, 
    city,
    order_date,
    first_name,
    last_name
FROM 
    SampleRetail.sale.orders AS O
JOIN SampleRetail.sale.customer AS C
ON O.customer_id = C.customer_id
WHERE city = 'Boulder'
ORDER BY order_date ASC

---- 6. Get the sales by staffs and years using the AVG() aggregate function.
SELECT
    S.first_name,
    S.last_name,
    YEAR(order_date) as 'Year',
    AVG(quantity*list_price*discount) as 'average_sales'
FROM
    SampleRetail.sale.orders as O
JOIN SampleRetail.sale.staff as S
ON O.staff_id = S.staff_id
JOIN SampleRetail.sale.order_item as I
ON O.order_id = I.order_id
GROUP BY
    S.first_name,
    S.last_name,
    YEAR(order_date)

---- 7. What is the sales quantity of product according to the brands and sort them highest-lowest----
SELECT brand_name, SUM(quantity) sum
FROM sale.order_item AS O
JOIN product.product AS P
ON O.product_id = P.product_id
JOIN product.brand AS B
ON P.brand_id = B.brand_id
GROUP BY B.brand_name
ORDER BY [sum] DESC

SELECT brand_name, P.product_name, SUM(quantity) sum
FROM sale.order_item AS O
JOIN product.product AS P
ON O.product_id = P.product_id
JOIN product.brand AS B
ON P.brand_id = B.brand_id
GROUP BY B.brand_name, P.product_name
ORDER BY [sum] DESC

---- 8. What are the categories that each brand has?----
SELECT B.brand_name, C.category_name
FROM product.product AS P
JOIN product.category AS C
ON P.category_id = C.category_id
JOIN product.brand AS B
ON P.brand_id = B.brand_id
GROUP BY B.brand_name, C.category_name


---- 9. Select the avg prices according to brands and categories----
SELECT B.brand_name, C.category_name, CONVERT(DECIMAL(18,2),(AVG(list_price)))
FROM product.product AS P
JOIN product.category AS C
ON P.category_id = C.category_id
JOIN product.brand AS B
ON P.brand_id = B.brand_id
GROUP BY B.brand_name, C.category_name
ORDER BY B.brand_name, C.category_name

----?? 10. Select the annual amount of product produced according to brands----
SELECT brand_name, YEAR(order_date) year, CONVERT(MONEY,SUM(OI.list_price*quantity*(1-discount)),1) annual_amount
FROM sale.order_item AS OI
JOIN product.product AS P
ON OI.product_id = P.product_id
JOIN product.brand AS B
ON P.brand_id = B.brand_id
JOIN sale.orders AS O
ON OI.order_id = O.order_id
GROUP BY YEAR(order_date), brand_name
ORDER BY annual_amount DESC


---- 11. Select the store which has the most sales quantity in 2016.----
SELECT store_name, YEAR(O.order_date) sale_year, SUM(quantity) sale_quantity
FROM sale.order_item AS OI
JOIN sale.orders AS O
ON OI.order_id = O.order_id
JOIN sale.store AS S
ON S.store_id = O.store_id
GROUP BY S.store_name, YEAR(O.order_date)
ORDER BY sale_quantity DESC

SELECT YEAR(order_date), COUNT(*)
FROM sale.order_item AS OI
JOIN sale.orders AS O
ON OI.order_id = O.order_id
GROUP BY YEAR(order_date)

---- 12 Select the store which has the most sales amount in 2018.----
SELECT TOP 1 store_name, YEAR(O.order_date) sale_year, SUM(list_price*quantity*(1-discount)) sale_amount
FROM sale.order_item AS OI
JOIN sale.orders AS O
ON OI.order_id = O.order_id
JOIN sale.store AS S
ON S.store_id = O.store_id
WHERE YEAR(O.order_date) = 2018
GROUP BY S.store_name, YEAR(O.order_date)
ORDER BY sale_amount DESC

---- 13. Select the personnel which has the most sales amount in 2019.----
SELECT TOP 1 S.staff_id, S.first_name, S.last_name, YEAR(O.order_date) sale_year, SUM(list_price*quantity*(1-discount)) sale_amount
FROM sale.order_item AS OI
JOIN sale.orders AS O
ON OI.order_id = O.order_id
JOIN sale.staff AS S
ON S.store_id = O.store_id
WHERE YEAR(O.order_date) = 2019
GROUP BY S.staff_id, S.first_name, S.last_name, YEAR(O.order_date)
ORDER BY sale_amount DESC
