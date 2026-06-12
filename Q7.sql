-- Review Ratings and Sales Performance
-- Product groups by rating and revenue performance

with product_ratings as (
    select 
        product_id,
        avg(rating) as avg_rating
    from reviews
    group by product_id
),

product_revenue as (
    select 
        oi.product_id,
        sum(oi.line_total) as total_revenue
    from order_items oi
    join orders o 
        on oi.order_id = o.order_id
    where o.order_status = 'Delivered'
    group by oi.product_id
),

combined as (
    select 
        p.product_id,
        p.unit_price,
        coalesce(pr.avg_rating,0) as avg_rating,
        coalesce(rv.total_revenue,0) as total_revenue
    from products p
    left join product_ratings pr 
        on p.product_id = pr.product_id
    left join product_revenue rv 
        on p.product_id = rv.product_id
),

segmented as (
    select *,
        case 
            when avg_rating >= 4.0 then 'High Rated'
            when avg_rating >= 3.0 then 'Mid Rated'
            else 'Low Rated'
        end as rating_group
    from combined
)

select 
    rating_group,
    count(*) as product_count,
    sum(total_revenue) as total_revenue,
    round(avg(unit_price),2) as avg_unit_price
from segmented
group by rating_group
order by total_revenue desc;