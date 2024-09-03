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

Case Study Questions
1. What is the total amount each customer spent at the restaurant?
select dannys_diner.sales.customer_id,sum(dannys_diner.menu.price) from dannys_diner.sales join dannys_diner.menu on dannys_diner.menu.product_id=dannys_diner.sales.product_id
group by dannys_diner.sales.customer_id
order by dannys_diner.sales.customer_id

2. How many days has each customer visited the restaurant?
select dannys_diner.sales.customer_id,count(distinct dannys_diner.sales.order_date) from dannys_diner.sales
group by dannys_diner.sales.customer_id
order by dannys_diner.sales.customer_id

3. What was the first item from the menu purchased by each customer?
with cte as(select dannys_diner.sales.customer_id,dannys_diner.sales.product_id,dannys_diner.sales.order_date,
row_number() over(partition by dannys_diner.sales.customer_id order by dannys_diner.sales.order_date) as rn from dannys_diner.sales)

select cte.customer_id,dannys_diner.menu.product_name from cte 
join dannys_diner.menu on dannys_diner.menu.product_id=cte.product_id where cte.rn=1

4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select count(dannys_diner.sales.product_id) as max_purchased_item,dannys_diner.menu.product_name from dannys_diner.sales join dannys_diner.menu
on dannys_diner.sales.product_id=dannys_diner.menu.product_id
group by dannys_diner.sales.product_id,dannys_diner.menu.product_name
order by max_purchased_item desc
limit 1

5. Which item was the most popular for each customer?
with cte as(
select dannys_diner.sales.customer_id,dannys_diner.menu.product_name,
count(dannys_diner.sales.order_date) as no_of_orders,
row_number() over(partition by dannys_diner.sales.customer_id order by count(dannys_diner.sales.order_date)desc) as rn 
from dannys_diner.sales join dannys_diner.menu on dannys_diner.menu.product_id=dannys_diner.sales.product_id
group by dannys_diner.sales.customer_id,
dannys_diner.menu.product_name,)

select * from cte where rn=1

6. Which item was purchased first by the customer after they became a member?
with cte as(
select dannys_diner.members.customer_id, count(dannys_diner.sales.order_date) as no_of_orders ,dannys_diner.sales.order_date,dannys_diner.menu.product_name,
row_number() over(partition by dannys_diner.sales.customer_id order by dannys_diner.sales.order_date) as rn 
from dannys_diner.sales join dannys_diner.members on dannys_diner.sales.customer_id=dannys_diner.members.customer_id
join dannys_diner.menu on dannys_diner.menu.product_id=dannys_diner.sales.product_id
where dannys_diner.members.join_date<=dannys_diner.sales.order_date
  group by dannys_diner.members.customer_id,dannys_diner.menu.product_name,dannys_diner.sales.customer_id,dannys_diner.sales.order_date
  order by dannys_diner.sales.order_date
)

select * from cte where rn=1

7. Which item was purchased just before the customer became a member?
with cte as(
select dannys_diner.members.customer_id, count(dannys_diner.sales.order_date) as no_of_orders ,dannys_diner.sales.order_date,dannys_diner.menu.product_name,
row_number() over(partition by dannys_diner.sales.customer_id order by dannys_diner.sales.order_date desc) as rn 
from dannys_diner.sales join dannys_diner.members on dannys_diner.sales.customer_id=dannys_diner.members.customer_id
join dannys_diner.menu on dannys_diner.menu.product_id=dannys_diner.sales.product_id
where dannys_diner.members.join_date>dannys_diner.sales.order_date
  group by dannys_diner.members.customer_id,dannys_diner.menu.product_name,dannys_diner.sales.customer_id,dannys_diner.sales.order_date
  order by dannys_diner.sales.order_date
)

select * from cte where rn=1

8. What is the total items and amount spent for each member before they became a member?
select dannys_diner.members.customer_id, count(dannys_diner.sales.order_date) as no_of_items ,sum(dannys_diner.menu.price) as amount_spent 
from dannys_diner.sales join dannys_diner.members on dannys_diner.sales.customer_id=dannys_diner.members.customer_id
join dannys_diner.menu on dannys_diner.menu.product_id=dannys_diner.sales.product_id
where dannys_diner.members.join_date>dannys_diner.sales.order_date
  group by dannys_diner.members.customer_id,dannys_diner.sales.customer_id

9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select dannys_diner.sales.customer_id,sum(case when dannys_diner.menu.product_name='sushi' then dannys_diner.menu.price*10*2
 else dannys_diner.menu.price*10 end)as points from dannys_diner.sales join dannys_diner.menu on dannys_diner.menu.product_id=dannys_diner.sales.product_id
 group by dannys_diner.sales.customer_id

10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - 
how many points do customer A and B have at the end of January?
select dannys_diner.sales.customer_id,sum(dannys_diner.menu.price*10*2) as points from dannys_diner.sales join dannys_diner.members on dannys_diner.sales.customer_id=dannys_diner.members.customer_id
join dannys_diner.menu on dannys_diner.menu.product_id=dannys_diner.sales.product_id
where dannys_diner.sales.order_date between dannys_diner.members.join_date and '2021-01-31'
group by dannys_diner.sales.customer_id
