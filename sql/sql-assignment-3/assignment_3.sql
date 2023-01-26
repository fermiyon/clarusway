/*
Discount Effects

Generate a report including product IDs and discount effects on 
whether the increase in the discount rate positively impacts the number of orders for the products.

In this assignment, you are expected to generate a solution using SQL with a logical approach. 

POSITIVE, NEGATIVE, NEUTRAL
*/

-- ilk bakis
SELECT *
FROM product.product

SELECT *
FROM sale.order_item

SELECT *
FROM sale.orders

SELECT 
    P.product_id, OI.order_id, item_id, quantity, P.list_price, discount, order_date
FROM 
    product.product P
    JOIN
    sale.order_item OI ON P.product_id = OI.product_id
    JOIN
    sale.orders O ON OI.order_id = O.order_id
ORDER BY product_id, order_date

SELECT 
    P.product_id, SUM(quantity) total_quantity, discount
FROM 
    product.product P
    JOIN
    sale.order_item OI ON P.product_id = OI.product_id
GROUP BY P.product_id, P.list_price, discount
ORDER BY product_id, discount

-- First solution

;WITH sales_data AS (
    SELECT 
        P.product_id, SUM(quantity) total_sale, discount
    FROM 
        product.product P
        JOIN
        sale.order_item OI ON P.product_id = OI.product_id
    GROUP BY P.product_id, discount
),
summary AS (
  SELECT 
    product_id,
    discount as x,
    total_sale as y,
    discount * total_sale as xy,
    discount * discount as x_squared
  FROM sales_data
),
summary_regression AS (
  SELECT 
    product_id,
    SUM(y) as sum_y, 
    SUM(x) as sum_x, 
    SUM(xy) sum_xy, 
    SUM(x_squared) as sum_x_squared, 
    COUNT(x) as n
  FROM summary
  GROUP BY product_id
)
,regression AS (
  SELECT 
    product_id,
    CASE
        WHEN (n*sum_x_squared - sum_x * sum_x) <> 0 THEN (n*sum_xy - sum_x * sum_y) / (n*sum_x_squared - sum_x * sum_x)
        ELSE NULL
    END as slope
  FROM summary_regression
)
--SELECT * FROM regression ORDER BY product_id
SELECT 
  product_id,
  CASE 
    WHEN slope > 0 THEN 'Positive'
    WHEN slope < 0 THEN 'Negative'
    ELSE 'Neutral'
  END as effect
FROM regression
ORDER BY product_id