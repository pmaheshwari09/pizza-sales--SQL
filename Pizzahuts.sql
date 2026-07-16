#Retrieve the total number of orders placed.
SELECT COUNT(*)
FROM orders;

#Calculate the total revenue generated from pizza sales.
SELECT ROUND(SUM(order_details.quantity * pizzas.price),2) AS 'total_revenue'
FROM pizzas
JOIN order_details 
ON order_details.pizza_id= pizzas.pizza_id;

#Identify The Highest Pizza Price.
SELECT pizza_types.name, pizzas.price
FROM pizzas
JOIN pizza_types
ON pizzas.pizza_type_id=pizza_types.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

#Identify the most common pizza size ordered.
SELECT COUNT(order_details.quantity) AS 'highest_rank' , pizzas.size
FROM pizzas
JOIN order_details
ON pizzas.pizza_id=order_details.pizza_id
GROUP BY pizzas.size
ORDER BY highest_rank DESC;

#List the top 5 most ordered pizza types along with their quantities.
SELECT pizza_types.name,SUM(order_details.quantity) AS 'quant'
FROM pizza_types
JOIN pizzas
ON pizzas.pizza_type_id = pizza_types.pizza_type_id 
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quant DESC
LIMIT 5;

#Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT pizza_types.category,SUM(order_details.quantity) AS 'quant'
FROM pizza_types
JOIN pizzas
ON pizzas.pizza_type_id = pizza_types.pizza_type_id 
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quant DESC;

#Determine the distribution of orders by hour of the day
SELECT Hour(time), COUNT(order_id)
FROM orders
GROUP BY Hour(time);

#Join relevant tables to find the category wise distribuation of pizzas.
SELECT category, COUNT(name)
FROM pizza_types
GROUP BY category;

#Group the orders by the date and calculate the average number of pizzas ordered per day.
SELECT orders.date, Sum(order_details.quantity)
FROM orders 
JOIN order_details
ON orders.order_id = order_details.order_id
GROUP BY orders.date;


#Dterine the top 3 most ordered pizza types based on revenue
SELECT pizza_types.name, ROUND(SUM(pizzas.price * order_details.quantity),2) AS total_revenue
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY total_revenue DESC
LIMIT 3;

#Calculate the percentage contribution of each pizza type to total revenue.
SELECT pizza_types.category,
 ROUND(SUM(order_details.quantity* pizzas.price)/(
 SELECT 
SUM(order_details.quantity* pizzas.price)AS total_revenue
fROM order_details
JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id)*100,2) AS percentage
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY percentage DESC;

#Analyze the cumulative revenue generated over time.
SELECT date, 
SUM(revenue) OVER (ORDER BY date) AS Cum_Revenue
FROM 
(SELECT orders.date,
SUM(order_details.quantity * pizzas.price) AS revenue
FROM order_details
JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id
JOIN orders
ON order_details.order_id = orders.order_id
GROUP BY orders.date) AS sales;

#Determine the top 3 most ordered pizza type based on revenue for each pizza category.
SELECT name, revenue
FROM 
(SELECT category,name, revenue,
RANK() over (PARTITION BY category ORDER BY revenue DESC) AS rk
FROM 
(SELECT pizza_types.category, pizza_types.name,
SUM((order_details.quantity) * pizzas.price) AS revenue 
FROM pizza_types
JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category, pizza_types.name) AS a) AS b
WHERE rk <=3;