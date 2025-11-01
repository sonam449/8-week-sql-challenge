-- This Part this creating 6 tables required for solving the problems statements. (runner_orders, runners, customers_orders, pizza_names, pizza_reciepes, pizza_toppings)
-- creating and using pizza_runner database
CREATE database pizza_runner;
use pizza_runner;

-- creating runners table
DROP table if exists runners;
CREATE TABLE    runners(
  runner_id INTEGER,
  registration_date DATE
);
-- inserting into runners table
INSERT INTO runners
  (runner_id, registration_date )
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');

-- creating customer_orders table
DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
   order_id  INTEGER,
   customer_id  INTEGER,
   pizza_id  INTEGER,
   exclusions  VARCHAR(4),
   extras  VARCHAR(4),
   order_time  TIMESTAMP
);
-- inserting into customer_orders table
INSERT INTO customer_orders
  (order_id , customer_id, pizza_id, exclusions, extras, order_time )
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


-- creating runner_orders table
DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
   order_id  INTEGER,
   runner_id  INTEGER,
   pickup_time  VARCHAR(19),
   distance  VARCHAR(7),
   duration  VARCHAR(10),
   cancellation  VARCHAR(23)
);
-- inserting into runner_orders table
INSERT INTO runner_orders
  (order_id , runner_id, pickup_time, distance, duration, cancellation )
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


-- creating pizza_names table
DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
   pizza_id  INTEGER,
   pizza_name  TEXT
);
-- inserting into pizza_names table
INSERT INTO pizza_names
  (pizza_id , pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


-- creating pizza_recipes table
DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
   pizza_id  INTEGER,
   toppings  TEXT
);
-- inserting into pizza_recipes table
INSERT INTO pizza_recipes
  (pizza_id , toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');

-- creating pizza_toppings table
DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
   topping_id  INTEGER,
   topping_name  TEXT
);
-- inserting into pizza_toppings table
INSERT INTO pizza_toppings
  (topping_id , topping_name )
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');



-- Section A. Pizza Metrics

-- Q 1 - How many pizzas were ordered?
select count(pizza_id) as total_pizza
from customer_orders;

-- q 2 - How many unique customer orders were made?
select count(distinct(order_id)) as Unique_cust_orders
from customer_orders;

-- q3 -- How many successful orders were delivered by each runner?
select runner_id, count(order_id) as Success_delivery
from runner_orders
WHERE duration <> 'null'
group by runner_id
order by runner_id;

-- q4 -- How many of each type of pizza was delivered?
select c.pizza_id, pn.pizza_name, count(c.pizza_id)
from customer_orders c 
join runner_orders r
on c.order_id = r.order_id and r.duration<> 'null'
join pizza_names pn 
on pn.pizza_id = c.pizza_id
group by c.pizza_id,pn.pizza_name ;

-- q5 - How many Vegetarian and Meatlovers were ordered by each customer?
select c.customer_id,c.pizza_id, count(c.pizza_id)
from customer_orders c join pizza_names pn
on c.pizza_id = pn.pizza_id
group by c.customer_id, c.pizza_id;

-- q6 - What was the maximum number of pizzas delivered in a single order?
select c.order_id, count(c.pizza_id) 
from customer_orders c
join runner_orders ro on c.order_id = ro.order_id where ro.pickup_time <> 'null'
group by c.order_id 
order by count(c.pizza_id) desc
limit 1;

-- q7 -- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
-- here we need 3 conditions for each column (null, 'null' and length(columnvalue))
SELECT 
  customer_id, 
  SUM(CASE WHEN (exclusions IS NULL OR exclusions = 'null' OR TRIM(exclusions) = '') 
       AND (extras IS NULL OR extras = 'null' OR TRIM(extras) = '') 
      THEN 1 ELSE 0 END
  ) AS NoChangeCount,
  SUM(CASE WHEN (exclusions IS NOT NULL AND exclusions <> 'null' AND TRIM(exclusions) <> '') 
       OR (extras IS NOT NULL AND extras <> 'null' AND TRIM(extras) <> '') 
      THEN 1 ELSE 0 END
  ) AS ChangeCount
FROM customer_orders
GROUP BY customer_id;


-- q8 - How many pizzas were delivered that had both exclusions and extras?
SELECT 
SUM(case when (exclusions is NOT null AND (exclusions) <> 'null' AND length(exclusions)>0) and (extras is NOT null AND (extras) <> 'null' AND length(extras) > 0) then 1 end) as changecount
FROM CUSTOMER_ORDERS;


-- q9 - What was the total volume of pizzas ordered for each hour of the day?
SELECT date(order_time) orderdate, hour(order_time) ordertime, 
COUNT(order_id) totalOrder
from customer_orders
group by date(order_time), hour(order_time);

-- q10 - What was the volume of orders for each day of the week?
SELECT month(order_time), dayname(order_time), 
COUNT(order_id) HourCount
from customer_orders
group by month(order_time), dayname(order_time);


-- data cleaning and transformation - some datatypes and null values of columns needs to be changed before doing any problem solving








