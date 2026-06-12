-- Customer Acquisition & 30-Day Conversion
-- Top 5 connversion rate percentage by state in 2024

with customers_2024 as (
    select 
        customer_id,
        state,
        signup_date
    from customers
    where signup_date >= '2024-01-01'
    and signup_date < '2025-01-01'
),

first_orders as (
    select 
        customer_id,
        min(order_date) as first_order_date
    from orders
    group by customer_id
),

conversion_flag as (
    select 
        c.customer_id,
        c.state,
        c.signup_date,
        f.first_order_date,
        case 
            when f.first_order_date <= c.signup_date + interval '30 days'
            then 1
            else 0
        end as converted_30d
    from customers_2024 c
    left join first_orders f 
        on c.customer_id = f.customer_id
)

select 
    state,
    count(*) as new_customers,
    sum(converted_30d) as converted_customers,
    round(
        100.0 * sum(converted_30d) / count(*),
        2
    ) as conversion_rate_percent
from conversion_flag
group by state
order by new_customers desc
limit 5;