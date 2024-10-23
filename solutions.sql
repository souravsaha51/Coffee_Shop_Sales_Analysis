--   Coffee Data Analysis        

select * from city;
select * from products;
select * from customers;
select * from sales;

--  Reports & Data Analysis

--  Q.1 Coffee Customers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?


SELECT city_name, (population * 0.25) AS coffee_consumers, city_rank
FROM city
order by 2 desc

--  Q.2 Total Revenue from coffe sales
-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?

SELECT
	ci.city_name, 
	SUM(s.total) AS total_revenue
FROM sales s
JOIN customers c
ON s.customer_id = c.customer_id
JOIN city ci
ON ci.city_id = c.city_id
WHERE s.sale_date BETWEEN '2023-10-01' AND '2023-12-31'
GROUP BY 1
ORDER BY total_revenue DESC;


--  Q.3 Sales Count each product
-- How many units of each coffee product have been sold?

select
p.product_name,
count(s.sale_id) as total_orders
from products as p
left join sales as s
on s.product_id = p.product_id
group by 1
order by 2 desc




--  Q.4 Average Sales Amount per City
-- What is the average sales amount per customer in each city

SELECT
	ci.city_name, 
	SUM(s.total) AS total_revenue,
	count(distinct s.customer_id) as total_customer,
	round(
		sum(s.total)::numeric/
		  count(distinct s.customer_id)::numeric, 2) as avg_sal_per_cus
FROM sales s
join customers as c
on s.customer_id = c.customer_id
join city as ci
on ci.city_id = c.city_id
GROUP BY 1
ORDER BY 2 DESC;



--  Q.5 City Population and Coffee Consumers
-- Provide a list of cities along with their populations and estimated coffee consumers
-- return city_name, total current customer, estimate coffee consumers (25%)

SELECT city.city_name, 
       COUNT(customers.customer_id) AS total_customers, 
       city.population, 
       (city.population * 0.25) AS estimated_coffee_consumers
FROM city
LEFT JOIN customers ON city.city_id = customers.city_id
GROUP BY city.city_name, city.population
ORDER BY estimated_coffee_consumers DESC;






--  Q.6 Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume
select *
from -- table
(
select 
	ci.city_name,
	p.product_name,
	count(s.sale_id) as total_orders,
	dense_rank() over(partition by ci.city_name order by count(s.sale_id) desc) as rank
from sales as s
join products as p
on s.product_id = p.product_id
join customers as c
on c.customer_id = s.customer_id
join city as ci
on ci.city_id = c.city_id
group by 1, 2
	) as t1
-- order by 1, 3 desc
where rank <=3





--  Q.7 Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?

SELECT city.city_name, 
       COUNT(DISTINCT customers.customer_id) AS unique_customers
FROM sales
JOIN customers ON sales.customer_id = customers.customer_id
JOIN city ON customers.city_id = city.city_id
JOIN products ON sales.product_id = products.product_id
WHERE products.product_name ILIKE '%coffee%'
GROUP BY city.city_name
ORDER BY unique_customers DESC;





--  Q.8 Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer

SELECT city.city_name, 
       ROUND(AVG(sales.total)::numeric, 2) AS avg_sale_per_customer, 
       ROUND((city.estimated_rent / COUNT(DISTINCT customers.customer_id))::numeric, 2) AS avg_rent_per_customer
FROM sales
JOIN customers ON sales.customer_id = customers.customer_id
JOIN city ON customers.city_id = city.city_id
GROUP BY city.city_name, city.estimated_rent
ORDER BY avg_sale_per_customer DESC;







--  Q.9 Customer Retention Rate
-- How many customers have made repeat purchases
SELECT city.city_name, 
       COUNT(DISTINCT customers.customer_id) AS repeat_customers
FROM sales
JOIN customers ON sales.customer_id = customers.customer_id
JOIN city ON customers.city_id = city.city_id
WHERE customers.customer_id IN (
    SELECT customer_id
    FROM sales
    GROUP BY customer_id
    HAVING COUNT(sale_id) > 1
)
GROUP BY city.city_name
ORDER BY repeat_customers DESC;



--  Q.10 Total Sales by Product Category
-- What is the total sales value for each product category?
SELECT products.product_name, 
       SUM(sales.total) AS total_sales
FROM sales
JOIN products ON sales.product_id = products.product_id
GROUP BY products.product_name
ORDER BY total_sales DESC;


