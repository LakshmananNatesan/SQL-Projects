CREATE DATABASE sales_data_db;
SHOW DATABASES;

USE sales_data_db;

SELECT *
FROM orders
WHERE Order_Id;

drop table orders;

CREATE TABLE df7_orders (
    order_id INT PRIMARY KEY,
    order_date DATE,
    ship_mode VARCHAR(20),
    segment VARCHAR(20),
    country VARCHAR(20),
    city VARCHAR(20),
    state VARCHAR(20),
    postal_code VARCHAR(20),
    region VARCHAR(20),
    category VARCHAR(20),
    sub_category VARCHAR(20),
    product_id VARCHAR(50),
    cost_price DECIMAL(7,2),
    List_Price DECIMAL(7,2),
    Quantity INT,
    Discount_Percent DECIMAL(7,2),
    discount DECIMAL(7,2),
    sale_price DECIMAL(7,2),
    profit DECIMAL(7,2)
);


WITH CTE1 AS (
SELECT  * , ROW_NUMBER() OVER (
partition by ship_mode,segment,country,city,state,postal_Code,region,category,sub_category,product_id) AS row_num
FROM df7_orders)

SELECT *
from CTE1
WHERE row_num > 1 AND region = 'East';

SELECT *
FROM df7_orders
WHERE ship_mode = 'First Class';





SELECT  product_id,SUM(sale_price) as saleprice
FROM df7_orders
GROUP BY product_id
ORDER  BY saleprice DESC
LIMIT 10;

-- find top 5 selling prodcuts in each region
WITH CTE2 AS (
SELECT product_id,SUM(sale_price) AS sales ,region
from df7_orders
GROUP BY product_id,region
ORDER BY region,sales DESC ),RANKINGREGION AS
(
SELECT *,DENSE_RANK() OVER (PARTITION BY region ORDER BY sales DESC ) AS ranking
FROM CTE2)

SELECT *
FROM RANKINGREGION
WHERE Ranking <=5;


----------------------
WITH CTE AS (
SELECT YEAR( order_date) order_year,MONTH(order_date)order_month,SUM(sale_price) AS sales
FROM df7_orders
GROUP BY order_year,order_month)

SELECT order_month
,SUM(case when order_year = 2022 then sales ELSE 0 end) AS sales2022
,SUM(case when order_year = 2023 then sales ELSE 0 end ) AS sales2023
FROM CTE
GROUP BY order_month
ORDER BY order_month;

-- for each category which month has highest sales
 WITH CTE AS  (
SELECT category,
       SUM(sale_price) AS sales,
       DATE_FORMAT(order_date, '%Y%m') AS order_month
FROM df7_orders
GROUP BY category, DATE_FORMAT(order_date, '%Y%m')),CTER AS (
SELECT *, DENSE_RANK () OVER ( PARTITION BY category ORDER BY sales DESC) AS ranking_na
FROM CTE)

SELECT *
FROM CTER
WHERE ranking_na = 1;

-- which sub category has highest growth profit n 2023 compare to 2022




WITH CTE AS (
SELECT sub_category,YEAR( order_date) order_year,SUM(sale_price) AS sales
FROM df7_orders
GROUP BY order_year,sub_category),CTE2 AS (
SELECT sub_category
,SUM(case when order_year = 2022 then sales ELSE 0 end) AS sales2022
,SUM(case when order_year = 2023 then sales ELSE 0 end ) AS sales2023
FROM CTE
GROUP BY sub_category)

SELECT *,(sales2023-sales2022)*100/sales2022
FROM CTE2
ORDER BY (sales2023-sales2022)*100/sales2022 DESC
LIMIT 1;




