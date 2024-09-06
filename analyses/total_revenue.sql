with

summary as (
    select
        payment_method,
        sum(amount) as total_amount
    from
        {{ ref('stg_stripe__payments') }}
    where status = 'success'
    group by payment_method
)

select * 
from summary