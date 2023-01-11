
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


---- 8. What are the categories that each brand has?----


---- 9. Select the avg prices according to brands and categories----


---- 10. Select the annual amount of product produced according to brands----


---- 11. Select the store which has the most sales quantity in 2016.----


---- 12 Select the store which has the most sales amount in 2018.----


---- 13. Select the personnel which has the most sales amount in 2019.----

