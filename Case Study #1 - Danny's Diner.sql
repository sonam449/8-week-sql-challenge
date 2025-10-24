-- Below code is used for creating and updating the data in 3 tables (Sales, Members and Menu).
-- later on the 10 questions of this cases study is solved.
create database DannyDiner;
CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
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
  product_id INTEGER,
  product_name  VARCHAR(5),
   price  INTEGER
);

INSERT INTO menu
  ( product_id ,  product_name ,  price )
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
   customer_id  VARCHAR(1),
   join_date  DATE
);

INSERT INTO members
  ( customer_id ,  join_date )
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  
  
  
  /* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
select s.customer_id,
sum(m.price)
from sales s join menu m
on s.product_id = m.product_id
group by s.customer_id;

-- 2. How many days has each customer visited the restaurant?
select customer_id, count(order_date)
from sales
group by customer_id;

-- 3. What was the first item from the menu purchased by each customer?
select s.customer_id, group_concat(m.product_name order by m.product_name separator ', ') as firstItems
from sales s join menu m 
on s.product_id = m.product_id
where s.order_date = (select min(s2.order_date) from sales s2 WHERE s2.customer_id = s.customer_id)
group by s.customer_id;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select s.product_id, count(s.product_id), m.product_name
from sales s join menu m on s.product_id = m.product_id
group by s.product_id, m.product_name
order by count(s.product_id) desc limit 1;

-- 5. Which item was the most popular for each customer?
select ranked.customer_id, ranked.product_id, ranked.product_name
from (select 
	s.customer_id,
	s.product_id, m.product_name,
	row_number() over (partition by s.customer_id order by count(s.product_id) desc) rownum
	from sales s 
    join menu m
    on s.product_id = m.product_id
	group by s.customer_id, s.product_id, m.product_name)ranked
where rownum = 1; -- having is evaluated before window function thats why using subquery!


-- 6. Which item was purchased first by the customer after they became a member?
select group_concat(s.product_id order by s.product_id separator ', ') productids, mm.join_date, s.customer_id
from sales s
join members mm
on s.customer_id = mm.customer_id
where s.order_date = (select min(s1.order_date) from sales s1 where mm.join_date <= s1.order_date and s.customer_id = s1.customer_id)
group by  s.customer_id, mm.join_date;

-- or method 2 (using window function) 
select x.customer_id, x.order_date, x.product_id
from (
	select s.customer_id, mm.join_date, s.order_date, s.product_id,
    rank() over (partition by s.customer_id order by s.order_date asc) ranked
    from sales s join members mm
    on s.customer_id = mm.customer_id and mm.join_date <= s.order_date
)x
where x.ranked = 1;

-- 7. Which item was purchased just before the customer became a member?
select group_concat(s.product_id order by s.product_id separator ', ') productids, mm.join_date, s.customer_id
from sales s
join members mm
on s.customer_id = mm.customer_id
where s.order_date = (select max(s1.order_date) from sales s1 where mm.join_date >= s1.order_date and s.customer_id = s1.customer_id)
group by  s.customer_id, mm.join_date;

-- method 2
select x.customer_id, x.order_date, x.product_id
from (
	select s.customer_id, s.order_date, s.product_id, mm.join_date, rank() over (partition by s.customer_id order by s.order_date desc) ranked
    from sales s join members mm
    on s.customer_id = mm.customer_id and mm.join_date >= s.order_date)x
    
    where x.ranked = 1;

-- 8. What is the total items and amount spent from each member before they became a member?
select s.customer_id, count(s.product_id) totalItems, sum(price) totalAmount
from sales s join menu m 
on s.product_id = m.product_id
group by s.customer_id;


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select s.customer_id, 
	sum(case when m.product_name != 'Sushi' then 10*price
			when m.product_name = 'Sushi' then 2*10*price end)
		as totalPoints
        
        from sales s join menu m 
        on s.product_id = m.product_id 
        group by s.customer_id;


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
-- not just sushi - how many points do customer A and B have at the end of January?
select s.customer_id, 
sum(case WHEN s.order_date BETWEEN mm.join_date AND DATE_ADD(mm.join_date, INTERVAL 7 DAY)
                 THEN 2 * 10 * m.price   -- double points in first week after joining
            WHEN m.product_name = 'Sushi' 
                 THEN 2 * 10 * m.price   -- sushi always 2x points
            ELSE 10 * m.price end) totalpoints
        
        from sales s join members mm on s.customer_id = mm.customer_id
					 join menu m on s.product_id = m.product_id
                     
group by s.customer_id;                     


