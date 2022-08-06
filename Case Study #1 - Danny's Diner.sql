-- SCHEMA

CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
/*--------------------------------------------------------------------*/
 -- Q1 What is the total amount each customer spent at the restaurant?
 
select 
  customer_id,
  sum(price)
from 
  dannys_diner.sales as s
left join 
  dannys_diner.menu as m
on 
  s.product_id = m.product_id
group by 
  customer_id;

/*--------------------------------------------------------------------*/
-- Q2 How many days has each customer visited the restaurant?

select 
  customer_id,
  count(distinct(order_date)) as days
from 
  dannys_diner.sales 
group by 
  customer_id

/*-------------------------------------------------------------------*/
-- Q3 What was the first item from the menu purchased by each customer?

WITH new_table AS (
SELECT 
  customer_id, 
  order_date, 
  product_name,
  row_number() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS seq
FROM 
  dannys_diner.sales as s
LEFT JOIN 
  dannys_diner.menu as d
ON 
  s.product_id = d.product_id
)

SELECT 
  customer_id, 
  product_name
FROM 
  new_table
WHERE 
  seq = 1
  
-------------------------------------------------------
-- Q4 What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT 
  d.product_name, 
  count(s.product_id)
FROM 
  dannys_diner.sales as s
LEFT JOIN 
  dannys_diner.menu as d
ON 
  s.product_id = d.product_id
GROUP BY 
  d.product_name
LIMIT 1;

/*------------------------------------------------------*/
-- Q5 Which item was the most popular for each customer?

WITH temp1 AS (
SELECT 
  s.customer_id,
  d.product_name, 
  rank() over(partition by s.customer_id order by count(s.product_id) desc) as ranks
FROM 
  dannys_diner.sales as s
LEFT JOIN 
  dannys_diner.menu as d
ON 
  s.product_id = d.product_id
GROUP BY 
  s.customer_id, d.product_name )

SELECT * 
FROM 
  temp1
WHERE 
  ranks = 1
ORDER BY 
  customer_id
 
/*--------------------------------------------------------------------*/
-- Q6 Which item was purchased first by the customer after they became a member?
 
WITH temp1 AS
(SELECT
  s.customer_id, 
  s.order_date, 
  x.product_name,
  rank() over(partition by s.customer_id order by s.order_date) as ranks
FROM
  dannys_diner.sales as s
LEFT JOIN
  dannys_diner.members as d
ON
  s.customer_id = d.customer_id
LEFT JOIN 
  dannys_diner.menu as x
ON 
  s.product_id = x.product_id
WHERE
  (s.order_date >= d.join_date))


SELECT 
  customer_id,
  order_date,
  product_name
FROM 
  temp1
WHERE
  ranks = 1

/*--------------------------------------------------------------------*/
-- Q7. Which item was purchased just before the customer became a member?

WITH temp1 AS
(SELECT
  s.customer_id, 
  s.order_date, 
  x.product_name,
  rank() over(partition by s.customer_id order by s.order_date desc) as ranks
FROM
  dannys_diner.sales as s
LEFT JOIN
  dannys_diner.members as d
ON
  s.customer_id = d.customer_id
LEFT JOIN 
  dannys_diner.menu as x
ON 
  s.product_id = x.product_id
WHERE
  (s.order_date < d.join_date))


SELECT 
  customer_id,
  order_date,
  product_name
FROM 
  temp1
WHERE
  ranks = 1

/*--------------------------------------------------------------------*/
-- Q8. What is the total items and amount spent for each member before they became a member?

-- What is the total items and amount spent for each member before they became a member?

WITH temp1 AS
(SELECT 
  s.customer_id,
  count(s.product_id),
  sum(x.price)
FROM
  dannys_diner.sales as s
LEFT JOIN 
  dannys_diner.menu as x
ON 
  s.product_id = x.product_id
LEFT JOIN 
  dannys_diner.members as d
ON
  s.customer_id = d.customer_id
WHERE 
  (s.order_date > d.join_date)
GROUP BY 
  s.customer_id)


SELECT * FROM temp1

/*--------------------------------------------------------------------*/
-- Q9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

WITH temp2 AS
(SELECT 
  s.customer_id,
  CASE
      WHEN d.price != 10 THEN d.price
      WHEN d.price = 10 THEN 2*d.price
  END Points
FROM 
  dannys_diner.sales as s
LEFT JOIN 
  dannys_diner.menu as d
ON 
  s.product_id = d.product_id)

SELECT 
  customer_id,
  sum(points)
FROM 
  temp2
GROUP BY 
  customer_id
  
/*--------------------------------------------------------------------*/
-- Q9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

WITH temp2 AS
(SELECT 
  s.customer_id,
  CASE
      WHEN d.price != 10 THEN d.price*10
      WHEN d.price = 10 THEN 2*d.price*10
  END Points
FROM 
  dannys_diner.sales as s
LEFT JOIN 
  dannys_diner.menu as d
ON 
  s.product_id = d.product_id)

SELECT 
  customer_id,
  sum(points)
FROM 
  temp2
GROUP BY 
  customer_id
  
/*--------------------------------------------------------------------*/
-- Q10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?


/*BONUS*/
SELECT 
	s.customer_id
    s.order_date
    x.product_name
    x.price
 	CASE 
    	WHEN s.order_date < d.join_date THEN 'N'
        WHEN s.order_date >= d.join_date THEN 'Y'
    END membe
FROM
  dannys_diner.sales as s
LEFT JOIN 
  dannys_diner.menu as x
ON 
  s.product_id = x.product_id
LEFT JOIN 
  dannys_diner.members as d
ON
  s.customer_id = d.customer_id
