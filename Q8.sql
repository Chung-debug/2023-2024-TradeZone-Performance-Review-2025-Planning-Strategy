-- Top Seller Bonus Qualification
-- Top 10 sellers in 2024 meeting performance criteria

with seller_revenue as (
    select 
        seller_id,
        count(*) as total_orders,
        sum(total_amount) as total_revenue
    from orders
    where order_status = 'Delivered'
    and order_date >= '2024-01-01'
    and order_date < '2025-01-01'
    group by seller_id
),

seller_ratings as (
    select 
        o.seller_id,
        avg(r.rating) as avg_rating
    from orders o
    join reviews r 
        on o.order_id = r.order_id
    group by o.seller_id
)

select 
    sr.seller_id,
    sr.total_orders,
    round(rt.avg_rating,2) as avg_rating,
    sr.total_revenue
from seller_revenue sr
join seller_ratings rt 
    on sr.seller_id = rt.seller_id
where sr.total_orders >= 10
and rt.avg_rating >= 4.0
order by sr.total_revenue desc
limit 10;