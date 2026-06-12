-- Prefered payment Method by State

with payment_stats as (
    select 
        c.state,
        p.payment_method,
        count(*) as transaction_count,
        sum(p.amount) as total_amount
    from payments p
    join orders o 
        on p.order_id = o.order_id
    join customers c 
        on o.customer_id = c.customer_id
    where o.order_status = 'Delivered'
    group by 
        c.state,
        p.payment_method
),

ranked as (
    select *,
        rank() over(
            partition by state 
            order by transaction_count desc
        ) as rnk
    from payment_stats
)

select 
    state,
    payment_method,
    transaction_count,
    total_amount,
    case 
        when rnk = 1 then 'Most Popular'
        else ''
    end as popularity_flag
from ranked
order by state, transaction_count desc;