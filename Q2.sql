-- Product Performance
-- Top 10 products by total revenue in 2024

select 
    p.product_name,
    p.category,
    sum(oi.line_total) as total_revenue,
    count(distinct oi.order_id) as total_orders
from order_items oi
join orders o 
    on oi.order_id = o.order_id
join products p 
    on oi.product_id = p.product_id
where o.order_date >= '2024-01-01'
and o.order_date < '2025-01-01'
and o.order_status not in ('Cancelled')
group by 
    p.product_name,
    p.category
order by total_revenue desc
limit 10;