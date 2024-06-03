-- Retrieve the total number of orders placed.
select count(order_id) as total_orders from orders;

-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(p.price * d.quantity), 2) AS total_revenue
FROM
    pizzas p
        JOIN
    order_details d ON p.pizza_id = d.pizza_id;
	
-- Identify the highest-priced pizza.
SELECT 
    t.name, p.price
FROM
    pizzas p
        JOIN
    pizza_types t ON t.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT 
    p.size AS pizza_size,
    COUNT(d.order_details_id) AS order_count
FROM
    pizzas p
        JOIN
    order_details d ON p.pizza_id = d.pizza_id
GROUP BY p.size
ORDER BY order_count DESC;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    t.name, SUM(d.quantity) AS quantity
FROM
    pizza_types t
        JOIN
    pizzas p ON p.pizza_type_id = t.pizza_type_id
        JOIN
    order_details d ON p.pizza_id = d.pizza_id
GROUP BY t.name
ORDER BY quantity DESC
LIMIT 5;

-- Join the necessary tables to find
-- the total quantity of each pizza category ordered.
SELECT 
    t.category, SUM(d.quantity) AS total_quantity
FROM
    pizza_types t
        JOIN
    pizzas p ON p.pizza_type_id = t.pizza_type_id
        JOIN
    order_details d ON d.pizza_id = p.pizza_id
GROUP BY t.category
ORDER BY total_quantity DESC;

-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS per_hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY per_hour
ORDER BY order_count DESC;

-- Join relevant tables to find 
-- the category-wise distribution of pizzas.
select category, count(name) as total_pizzas from pizza_types
group by category
order by total_pizzas desc;

-- Group the orders by date and 
-- calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity), 0) AS avg_pizzas_ordered_per_day
FROM
    (SELECT 
        o.order_date, SUM(d.quantity) AS quantity
    FROM
        orders o
    JOIN order_details d ON o.order_id = d.order_id
    GROUP BY o.order_date
    ORDER BY quantity DESC) AS order_quantity;
    
-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    t.name, SUM(d.quantity * p.price) AS revenue
FROM
    pizza_types t
        JOIN
    pizzas p ON t.pizza_type_id = p.pizza_type_id
        JOIN
    order_details d ON d.pizza_id = p.pizza_id
GROUP BY t.name
ORDER BY revenue DESC
LIMIT 3;



-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    t.category,
    ROUND(SUM(p.price * d.quantity), 2) AS revenue,
    ROUND((SUM(p.price * d.quantity) / (SELECT 
                    ROUND(SUM(p.price * d.quantity), 2) AS total_revenue
                FROM
                    pizzas p
                        JOIN
                    order_details d ON p.pizza_id = d.pizza_id)) * 100,
            2) AS pct_revenue
FROM
    pizza_types t
        JOIN
    pizzas p ON t.pizza_type_id = p.pizza_type_id
        JOIN
    order_details d ON d.pizza_id = p.pizza_id
GROUP BY t.category
ORDER BY pct_revenue DESC;

-- Analyze the cumulative revenue generated over time.
select order_date,
 round(sum(revenue) over(order by order_date),2) as cum_revenue
 from
 (select o.order_date, sum(d.quantity*p.price) as revenue
 from pizzas p 
 join order_details d
 on p.pizza_id=d.pizza_id
 join orders o
 on o.order_id=d.order_id
 group by order_date) as sales;
 
-- Determine the top 3 most ordered pizza types 
-- based on revenue for each pizza category.
select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn
from
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn
from
(select t.category, t.name, sum(p.price*d.quantity) as revenue
from pizza_types t
join pizzas p
on t.pizza_type_id=p.pizza_type_id
join order_details d 
on p.pizza_id=d.pizza_id
group by t.category, t.name) as a) as b
where rn <= 3;