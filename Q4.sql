-- Quarterly revenue trends
-- Compare quarterly revenue across 2023 and 2024 and identify growth in one table

with quarterly_metrics as (
    select 
        extract(year from order_date) as order_year,
        extract(quarter from order_date) as order_quarter,
        sum(total_amount) as total_revenue,
        avg(total_amount) as avg_order_value,
        count(*) as total_orders
    from orders
    where order_status = 'Delivered'
    group by 1, 2
)

select 
    q1.order_year, 
    q1.order_quarter, 
    round(q1.total_revenue, 2) as total_revenue, 
    round(q1.avg_order_value, 2) as avg_order_value, 
    q1.total_orders,
    -- calculate growth by joining the current quarter to the same quarter in the previous year
    round(q1.total_revenue - q2.total_revenue, 2) as revenue_growth
from quarterly_metrics q1
left join quarterly_metrics q2 
    on q1.order_quarter = q2.order_quarter 
    and q1.order_year = q2.order_year + 1
order by q1.order_year, q1.order_quarter;
