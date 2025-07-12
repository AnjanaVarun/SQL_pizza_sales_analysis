-- Retrieve the total number of orders placed.
SELECT 
    COUNT(*) AS Total_order_placed
FROM
    pizzacategory.orders;


-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS Total_revenue
FROM
    pizzacategory.order_details od
        JOIN
    pizzacategory.pizzas p ON od.pizza_id = p.pizza_id;


-- Identify the highest-priced pizza.
SELECT 
    pizza_types.name AS Name, pizzas.price AS Price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;


-- Identify the most common pizza size ordered.
SELECT 
    pizzas.size, COUNT(order_details.quantity) AS Total_quantity
FROM
    Pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY Total_quantity DESC
LIMIT 1;


-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name AS Pizza_name,
    SUM(order_details.quantity) AS Quantiies_sold
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON Order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY Quantiies_sold DESC
LIMIT 5	

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS Quantiies_ordered
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON Order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY Quantiies_ordered DESC


-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS Hour, COUNT(*) AS Total_orders
FROM
    Orders
GROUP BY Hour;

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category AS Category, COUNT(name) AS Quantity
FROM
    pizza_types
GROUP BY category; 
    

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(Quantity), 0) AS average_pizzas_ordered_per_day
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS Quantity
    FROM
        orders
    JOIN order_details ON order_details.order_id = orders.order_id
    GROUP BY orders.order_date) AS order_data
    
    
    -- Determine the top 3 most ordered pizza types based on revenue.
    Select pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS Revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY Revenue DESC
LIMIT 3


-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    CONCAT(round(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    SUM((pizzas.price * order_details.quantity))
                FROM
                    pizzas
                        JOIN
                    order_details ON pizzas.pizza_id = order_details.pizza_id) * 100 , 2),
            '%') AS revenue_contribution
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category


-- Analyze the cumulative revenue generated over time.
select order_date , round(sum(revenue) over (order by order_date) , 2) as cumulative_revenue 
from
(
select orders.order_date , sum(pizzas.price * order_details.quantity) as revenue
from orders
join order_details
on orders.order_id = order_details.order_id 
join pizzas
on pizzas.pizza_id = order_details.pizza_id
group by orders.order_date
) as sales


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
Select category as Category , name as Name, round(revenue, 2) as Revenue
from
(Select category , name , revenue ,
rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category , pizza_types.name ,
sum(pizzas.price * order_details.quantity) as revenue
from pizza_types
join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details
on pizzas.pizza_id = order_details.pizza_id 
group by pizza_types.category , pizza_types.name ) as a) as b
where rn <=3 ;