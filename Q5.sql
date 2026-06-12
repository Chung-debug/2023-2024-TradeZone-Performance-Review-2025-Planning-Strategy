-- Customer Spend Segmentation

with customer_spend as (
    select 
        customer_id,
        sum(total_amount) as total_spend
    from orders
    where order_date >= '2024-01-01'
    and order_date < '2025-01-01'
    and order_status = 'Delivered'
    group by customer_id
),

segmented as (
    select *,
        case 
            when total_spend >= 100000 then 'High Spenders'
            when total_spend >= 50000 then 'Medium Spenders'
            else 'Low Spenders'
        end as spend_segment
    from customer_spend
)

select 
    spend_segment,
    count(*) as customer_count,
    round(avg(total_spend),2) as avg_spend_per_customer,
    sum(total_spend) as total_revenue
from segmented
group by spend_segment
order by total_revenue desc;