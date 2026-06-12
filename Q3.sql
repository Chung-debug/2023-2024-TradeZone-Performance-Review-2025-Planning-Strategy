-- Seller Fulfilment Efficiency
-- Top 20 sellers with fastest avg fulfilment time (at least 20 completed orders)

with seller_metrics as (
    select 
        o.seller_id,
        -- cast dates to timestamp so extract(epoch) works to get seconds, then divide by 3600 for hours
        extract(epoch from (o.delivery_date::timestamp - o.order_date::timestamp))/3600 as delivery_hours,
        r.rating
    from orders o
    left join reviews r on o.order_id = r.order_id
    where o.delivery_date is not null 
      and o.order_date is not null 
      and o.order_status = 'Delivered'
)

select 
    seller_id,
    count(*) as completed_orders,
    round(avg(delivery_hours)::numeric, 2) as avg_fulfilment_hours,
    round(avg(rating)::numeric, 2) as avg_customer_rating
from seller_metrics
group by seller_id


having count(*) >= 20
order by avg_fulfilment_hours asc
limit 20;