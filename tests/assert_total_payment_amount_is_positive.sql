{{
    config(store_failures = true)
}}

select
    order_id, 
    amount
from {{ ref('fct_orders') }}
where amount < 0
