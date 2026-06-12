------------------------------------------------------------------------------------------------------------
-- DATA CLEANING
------------------------------------------------------------------------------------------------------------

-- Starting with the first key tables 'customers' and 'sellers'

--CUSTOMERS TABLE--

-- 1. checking missing, blank and duplicates values,  'customer_id' is a key column 
-- 	  and must not carry duplicates, blank entries or nulls
select *
from customers
where customer_id is null
or customer_id = ''; -- 16 nulls found, no empty strings

-- 2. Checking duplicates on customer_id
select customer_id, count(*)
from customers
group by customer_id
having count(*) > 1; -- no duplicates found

-- 3. Filling missing emails with 'No email provided'
update customers
set email = 'No email provided'
where email is null;

-- 4. Standardizing city and state names
update customers
set city = initcap(trim(city)),
	state = initcap(trim(state));

update customers 
set city = 'Lagos' 
where city = 'Lago S'; -- updating 'Lago S' to 'Lagos'

update customers 
set city = 'Port Harcourt'
where city = 'Port-Harcourt'; -- updating 'Port-Harcourt' to 'Port Harcourt'

update customers
set city = 'Port Harcourt'
where city = 'Portharcourt'; -- updating 'Portharcourt' to 'Port Harcourt'


--SELLERS TABLE--

-- 1. Checking nulls and blanks
select *
from sellers 
where sellers is null 
or seller_id = ''; -- no nulls or blanks 

-- 2. Checking for duplicates
select seller_id, count(*)
from sellers
group by seller_id
having count(*) > 1; -- no duplicates

-- 3. Standardizing values in product_category, city and state
 update sellers 
 set product_category = initcap(trim(product_category)),
 	 city = initcap(trim(city)),
 	 state = initcap(trim(state));

-- product_category
update sellers
	set product_category = case
	when product_category = 'Electronis' then 'Electronics' -- 'Electronis' to 'Electronics'
	when product_category = 'Fashon' then 'Fashion' -- 'Fashon' to 'Fashion'
	else product_category
end
where product_category in ('Electronis', 'Fashon'); 

update sellers 
set product_category = replace(product_category, '&', 'And') -- '&' to 'And'
where product_category like '%&%';

-- city
update sellers
	set city = case
	when city = 'Lago S' then 'Lagos' -- 'Lago S' to 'Lagos'
	when city = 'Portharcourt' then 'Port Harcourt' -- 'Portharcourt' to 'Port Harcourt'
	when city = 'Port-Harcourt' then 'Port Harcourt' -- 'Port-Harcourt' to 'Port Harcourt'
	else city
end
where city in ('Lago S', 'Portharcourt', 'Port-Harcourt'); 


--PRODUCTS TABLE--

-- 1. Checking nulls and blanks
select *
from products 
where products is null 
or product_id = ''; -- 4 nulls in unit price

--2 Checking duplicates on both IDs (product_id, seller_id)
select product_id, seller_id, count(*)
from products
group by product_id, seller_id
having count(*) > 1;

-- 3. Standardization of category
update products
set category = initcap(trim(category)) -- title casing

update products
	set category = case
	when category = 'Electronis' then 'Electronics' -- 'Electronis' to 'Electronics'
	when category = 'Fashon' then 'Fashion' -- 'Fashon' to 'Fashion'
	else category
end
where category in ('Electronis', 'Fashon'); 

update products 
set category = replace(category, '&', 'And') -- '&' to 'And'
where category like '%&%';

--4. Filling missing unit_price
update products p
set unit_price = sub.avg_price
from (
	select category, avg(unit_price) as avg_price
	from products 
	where unit_price is not null 
	group by category
)sub
where p.category = sub.category -- filling with the category average to keep the distribution untouched
and p.unit_price is null;


--ORDERS TABLE PART1--

-- 1. Checking nulls
select *
from orders 
where  not (orders is not null) 
or order_id = ''; -- 1581 rows with missing values in delivery_date and total_amount

-- 2. Checking duplicates
select seller_id, customer_id, order_id, count(*)
from orders 
group by seller_id, customer_id, order_id
having count(*) > 1; -- no duplicates found

-- Missing values will be filled after cleaning the related table, reviews  


--REVIEWS--

-- 1. Checking nulls
select count(*)
from reviews  
where reviews is null 
or order_id = ''; -- no nulls

-- 2. Checking duplicates
select product_id, customer_id, order_id, count(*)
from reviews 
group by product_id, customer_id, order_id
having count(*) > 1; -- two found, dropping them below

-- Removing the duplicates
delete from reviews
where review_id not in (
    select min(review_id)
    from reviews
    group by product_id, customer_id, order_id
);

-- 3. Standardizing ratings
update reviews 
set rating = case
	when rating > 5 then 5
	when rating < 1 then 1
	else rating
end
where rating > 5 or rating < 1;



--ORDERS TABLE PART2--

-- 1. Going back to fill in missing values on the orders table using values from cleaned reviews
update orders o
set delivery_date = r.review_date
from reviews r
where o.order_id = r.order_id
and o.delivery_date is null; -- there are no connected rows

-- 2. attempting to fill with average delivery period 
--avg delivery period in days
select round(avg(delivery_date - order_date)) as avg_delivery_days
from orders 
where delivery_date is not null 
and order_date is not null; -- avg_delivery_days = 5

-- 3. filling missing delivery date with average wait time; 5
update orders
set delivery_date = order_date + interval '5 days'
where delivery_date is null
and order_date is not null; -- 150 records with nulls remain without total_amount

-- 4. filling missing total_ammount with the sum of line_total
update orders o
set total_amount = sub.calculated_total
from(
select order_id, sum(line_total) as calculated_total
from order_items 
group by order_id
) sub
where o.order_id = sub.order_id
and o.total_amount is null -- all remaining 150 rows filled.



--ORDER ITEMS TABLE--

-- 1. Checking for nulls
select *
from order_items  
where order_items is null
or order_id = ''; -- 97 nulls on both unit_price and line_total

-- 2. Fill missing values -> get unit_from products and calculate line total
update order_items oi
set unit_price = p.unit_price
from products p
where oi.product_id = p.product_id 
and oi.unit_price is null; -- get unit_price from product table

-- Calculate line_total  
update order_items
set line_total = unit_price * quantity 
where line_total is null; -- multiplying unit_price*quantity

-- 3. Check duplicates
select item_id, count(*)
from order_items 
group by item_id
having count(*) > 1; -- no duplicates



--PAYMENTS--
-- 1. Checking nulls
select * 
from payments 
where payments is null; -- 155 nuls on amount

-- 2. Checking duplicates
select payment_id, count(*)
from payments 
group by payment_id
having count(*) > 1;

-- 3. Filling nulls
-- amount to total_amount from the orders table
select 
    p.payment_id, 
    p.order_id, 
    p.amount as payment_amount, 
    o.total_amount as order_total,
    p.payment_method
from payments p
left join orders o on p.order_id = o.order_id
where p.amount is null or p.amount = 0; -- all 155 null amounts match an order_id with total_amount

-- Filling amount with order_total
update payments p
set amount = o.total_amount
from orders o
where p.order_id = o.order_id
and p.amount is null;

-- 4. Checking duplicates
select *
from payments  
group by payment_id
having count(*) > 1; -- no duplicates found

-- 5. Standardizing time format
alter table payments add column payment_time time; -- add time column

update payments 
set payment_time = payment_date::time; -- seting payment date and time

alter table payments add column payment_date_new date; -- new date column

update payments 
set payment_date_new = payment_date::date; -- extracting date

alter table payments drop column payment_date; --dropping old date column

alter table payments rename column payment_date_new to payment_date; --rename new column to the old



--DATA VALIDATION--

-- flagging orders with > #10 discrepancy (difference greater than 10)
select 
	o.order_id,
	o.total_amount as recorded_amount,
	sum(oi.line_total) as items_total,
abs(o.total_amount - sum(oi.line_total)) as difference
from orders o
join order_items oi on o.order_id = oi.order_id 
group by o.order_id, o.total_amount 
having abs(o.total_amount - sum(oi.line_total)) > 10; -- 197 found

-- Check for negative product prices
select * from products 
where unit_price < 0; -- none found






