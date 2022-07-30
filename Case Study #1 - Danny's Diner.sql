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
 # Q1 What is the total amount each customer spent at the restaurant?
 
select customer_id, sum(price)
from dannys_diner.sales as s
left join dannys_diner.menu as m
on s.product_id = m.product_id
group by customer_id;

/*--------------------------------------------------------------------*/
# Q2 How many days has each customer visited the restaurant?

select customer_id, count(distinct(order_date)) days
from dannys_diner.sales 
group by customer_id

/*-------------------------------------------------------------------*/
# Q3 What was the first item from the menu purchased by each customer?

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
  
# -------------------------------------------------------
# Q4 