----1. Select the least 3 products in stock according to stores.
SELECT *
FROM product.stock

----2. Return the average number of sales orders in 2020 sales.

SELECT *
FROM sale.order_item

----3. Assign a rank to each product by list price in each brand and get products with rank less than or equal to three.
----4. Write a query that returns the highest daily turnover amount for each week on a yearly basis.
----5. Write a query that returns the cumulative distribution of the list price in the product table by brand.
SELECT
	brand_id, list_price,
	ROUND(CUME_DIST() OVER(PARTITION BY brand_id ORDER BY list_price), 3) cume_distr
FROM
	product.product

----6. Write a query that returns the relative standing of the list price in the product table by brand.
SELECT *
FROM product.product

SELECT
	brand_id, product_id, list_price,
	FORMAT(ROUND(PERCENT_RANK() OVER(PARTITION BY brand_id ORDER BY list_price), 3), 'P') percent_rnk
FROM
	product.product
----7. Divide customers into 5 groups based on the quantity of product they order.

;WITH CTE AS (
    SELECT customer_id, SUM(quantity) total_quantity
    FROM sale.order_item OI
        JOIN sale.orders O ON O.order_id= OI.order_id
    GROUP BY customer_id
)
SELECT
    *,
    NTILE(5) OVER (ORDER BY total_quantity) group_dist
FROM CTE
----8. List customers who have at least 2 consecutive orders are not shipped.

SELECT 
    customer_id, shipped_date,
    LEAD(shipped_date) OVER (PARTITION BY customer_id ORDER BY order_date) next_shipped_date
FROM sale.orders
ORDER BY customer_id, order_date