## 03_ Cosmetic Cleanups and CTE Groupings

This section is heavy on best practices, specifically [our own best practices](https://docs.getdbt.com/best-practices/how-we-style/0-how-we-style-our-dbt-projects) - we encourage you to create and follow your own!

#### Import CTEs at the top
1. The cosmetic cleanups in this video are listed below. Use this guideline to refactor the cosmetics of your `fct_customer_orders` model:
- Add whitespacing
- No lines over 80 characters
- Lowercased keywords

2. CTE restructuring
Refactor your code to follow this structure:
- with statement
- import CTEs
- logical CTEs
- final CTE
- simple select statement

Add a `with` statement to the top of your `fct_customer_orders` model

Add import CTEs after the `with` statement for each source table that the query uses. Ensure that subsequent `from` statements after the import CTEs reference the named CTEs rather than the `{{ source() }}`. We will focus on additional restructuring in the next section.

```sql
with 

-- Import CTEs

customers as (

  select * from {{ source('jaffle_shop', 'customers') }}

),

orders as (

  select * from {{ source('jaffle_shop', 'orders') }}

),

payments as (

  select * from {{ source('stripe', 'payment') }}

),

-- Logical CTEs
-- Final CTE
-- Simple Select Statment


paid_orders as (
    select orders.id as order_id,
        orders.user_id as customer_id,
        orders.order_date as order_placed_at,
        orders.status as order_status,
        p.total_amount_paid,
        p.payment_finalized_date,
        c.first_name as customer_first_name,
        c.last_name as customer_last_name
    from orders
    left join (
        select 
            orderid as order_id,
            max(created) as payment_finalized_date,
            sum(amount) / 100.0 as total_amount_paid
        from payments
        where status <> 'fail'
        group by 1
    ) p on orders.id = p.order_id
    left join customers as c on orders.user_id = c.id ),

customer_orders as (
    select 
        c.id as customer_id
        , min(order_date) as first_order_date
        , max(order_date) as most_recent_order_date
        , count(orders.id) as number_of_orders
    from customers as c 
    left join orders on orders.user_id = c.id 
    group by 1
)

select
    p.*,
    row_number() over (order by p.order_id) as transaction_seq,
    row_number() over (partition by customer_id order by p.order_id) as customer_sales_seq,
    case when c.first_order_date = p.order_placed_at
    then 'new'
    else 'return' end as nvsr,
    x.clv_bad as customer_lifetime_value,
    c.first_order_date as fdos
from paid_orders p
left join customer_orders as c using (customer_id)
left outer join 
(
    select
        p.order_id,
        sum(t2.total_amount_paid) as clv_bad
    from paid_orders p
    left join paid_orders t2 on p.customer_id = t2.customer_id and p.order_id >= t2.order_id
    group by 1
    order by p.order_id
) x on x.order_id = p.order_id
order by order_id
```

#### Pull out intermediates and simple subqueries
1. Move any simple subqueries into their own CTEs, and then reference those CTEs instead of the subquery.

2. Wrap the ultimate remaining `select` statement in a CTE and call this CTE `final`.

3. Add a simple select statement at the end: `select * from final`.

#### Remove join in favor of window functions + some cosmetic cleanup
1. This is specific to this query, but one of the subqueries and fields (`customer_lifetime_value`) would be better written as a window function to avoid an unnecessary extra self join. You could have made it one step better by making it a CTE rather than a subquery, but we are going to go 2 steps and just rewrite that bit of logic as a window.

2. Add comments for case-when or window functions to help out future you

#### Use fully qualified table names and references

At this point, I do some cleanup to make it easier to read, mostly fully qualifying column names and removing single letter aliases or other potentially confusing bits 

!["1"](./Pics/03_01%20Screen_Shot_2021-09-11_at_10.50.20_AM.png)

#### Simplify with window functions (FIX)

1. This is specific to this query, but I noticed one of the final columns was using a CTE to aggregate: `min(orders.order_date) as first_order_date` which could be simplified with a `first_value` window function. Here we are practicing continuous improvement - always looking for ways to make your code more terse or performant.

2. Remove the `customer_orders` CTE and join in the `final` CTE:

!["2"](./Pics/03_02%20Screen_Shot_2021-09-11_at_11.00.16_AM.png)

Followed by:

!["3"](./Pics/03_03%20Screen_Shot_2021-09-11_at_11.00.27_AM.png)

3. Change the transformation logic for the following two columns: `nvsr` & `fdos`

!["4"](./Pics/03_04%20Screen_Shot_2021-09-11_at_11.02.50_AM.png)

Followed by

!["5"](./Pics/03_05%20Screen_Shot_2021-09-11_at_11.03.10_AM.png)