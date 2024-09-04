## 04_ Centralizing Logic and Splitting Up Models

Your import files at the top of `fct_customer_orders.sql` are pulling directly from the source raw data, but we want that to happen it its own model, so future marts can reference those source files as well. We would like to create `staging` models to handle this import of the source and renaming potentially problematic fields in one place, so all future models can benefit from this.

1. Create files under `models > staging > jaffle_shop` called `stg_jaffle_shop__customers.sql` & `stg_jaffle_shop__orders.sql`. Here we are using the syntax `stg_<schema>__<object>.sql`.

2. Create a file under `models > staging > stripe` called `stg_stripe__payments`.

3. Paste the following into each file, keeping in mind: 
- Change `id` fields to `<object>_id`
- Make potentially clashing fields more specific, i.e. `status` becomes `order_status` 
- Rounding or simple transformations that you always want to happen in the future should be done here, i.e. we never want a dollar amount in cents, so we change `amount` to `round(amount / 100.0, 2) as payment_amount`

**models/staging/jaffle_shop/stg_jaffle_shop__customers.sql**
```sql
with 

source as (

  select * from {{ source('jaffle_shop', 'customers') }}

),

transformed as (

  select 

    id as customer_id,
    last_name as customer_last_name,
    first_name as customer_first_name,
    first_name || ' ' || last_name as full_name

  from source

)

select * from transformed
```

**models/staging/jaffle_shop/stg_jaffle_shop__orders.sql**
```sql
with 

source as (

    select * from {{ source('jaffle_shop', 'orders') }}

),

transformed as (

  select

    id as order_id,
    user_id as customer_id,
    order_date as order_placed_at,
    status as order_status,

    case 
        when status not in ('returned','return_pending') 
        then order_date 
    end as valid_order_date

  from source

)

select * from transformed
```

**models/staging/stripe/stg_stripe__payments.sql**
```sql
with 

source as (

    select * from {{ source('stripe', 'payment') }}

),

transformed as (

  select

    id as payment_id,
    orderid as order_id,
    created as payment_created_at,
    status as payment_status,
    round(amount / 100.0, 2) as payment_amount

  from source

)

select * from transformed
```

Now that you have moved some simple transformation logic back to the staging models, it's time to persist that transformation into `fct_customer_orders.sql` by:

1. Referencing the new staging models using the `{{ ref('<your_model>') }}` function

2. Changing any column reference from the original column names to the new column names (i.e. `id` instead of `customer_id`)

This looks like a lot of line changes, but it is fairly straightforward.

!["1"](./Pics/04_01%20Screen_Shot_2021-09-11_at_11.24.38_AM.png)

Paste this into your file if you want it to match perfectly with mine:

**models/marts/fct_customer_orders.sql**
```sql
with

-- Import CTEs

customers as (

  select * from {{ ref('stg_jaffle_shop__customers') }}

),

orders as (

  select * from {{ ref('stg_jaffle_shop__orders') }}

),

payments as (

  select * from {{ ref('stg_stripe__payments') }}

),

-- Logical CTEs

completed_payments as (

  select 
    order_id,
    max(payment_created_at) as payment_finalized_date,
    sum(payment_amount) as total_amount_paid
  from payments
  where payment_status <> 'fail'
  group by 1

),

paid_orders as (

  select 
    orders.order_id,
    orders.customer_id,
    orders.order_placed_at,
    orders.order_status,

    completed_payments.total_amount_paid,
    completed_payments.payment_finalized_date,

    customers.customer_first_name,
    customers.customer_last_name
  from orders
  left join completed_payments on orders.order_id = completed_payments.order_id
  left join customers on orders.customer_id = customers.customer_id

),

-- Final CTE

final as (

  select
    order_id,
    customer_id,
    order_placed_at,
    order_status,
    total_amount_paid,
    payment_finalized_date,
    customer_first_name,
    customer_last_name,

    -- sales transaction sequence
    row_number() over (order by order_id) as transaction_seq,

    -- customer sales sequence
    row_number() over (partition by customer_id order by order_id) as customer_sales_seq,

    -- new vs returning customer
    case  
      when (
      rank() over (
      partition by customer_id
      order by order_placed_at, order_id
      ) = 1
    ) then 'new'
    else 'return' end as nvsr,

    -- customer lifetime value
    sum(total_amount_paid) over (
      partition by customer_id
      order by order_placed_at
      ) as customer_lifetime_value,

    -- first day of sale
    first_value(order_placed_at) over (
      partition by customer_id
      order by order_placed_at
      ) as fdos

    from paid_orders
		
)

-- Simple Select Statement

select * from final
order by order_id
```

Lastly, some of the logic in your `fct_customer_orders.sql` we might want to reuse in later marts, such as `paid_orders` and `completed_payments`, so let's create an intermediate model with that logic which we can then reference in our fact model.

1. Under your `marts` folder, add a new file: `marts/intermediate/int_orders.sql`. This will add a new subfolder and file at the same time

2. Paste this into the `int_orders.sql` file:

**models/marts/intermediate/int_orders.sql**
```sql
with 

orders as (

  select * from {{ ref('stg_jaffle_shop__orders') }}

),

payments as (

  select * from {{ ref('stg_stripe__payments') }}

),

completed_payments as (

  select 
    order_id,
    max(payment_created_at) as payment_finalized_date,
    sum(payment_amount) as total_amount_paid
  from payments
  where payment_status <> 'fail'
  group by 1

),

paid_orders as (

  select 
    orders.order_id,
    orders.customer_id,
    orders.order_placed_at,
    orders.order_status,
    completed_payments.total_amount_paid,
    completed_payments.payment_finalized_date
  from orders
 left join completed_payments on orders.order_id = completed_payments.order_id
)

select * from paid_orders
```

3. Remove that same logic from `fct_customer_orders.sql`

!["2"](./Pics/04_02%20Screen_Shot_2021-09-11_at_11.45.25_AM.png)

4. Remove helper comments we added for the course (i.e. `- Import CTEs`)
5. 
6. In the final file, be more explicit with ordering of window function subclause. This fixes a future potential bug where if there are multiple orders placed on the same day for one customer ID, this would cause indeterminate ordering.

This is what you should end up with as the final file:

**models/marts/fct_customer_orders.sql**
```sql
with 

customers as (

  select * from {{ ref('stg_jaffle_shop__customers') }}

),

paid_orders as (

  select * from {{ ref('int_orders') }}

),

final as (

  select
    paid_orders.order_id,
    paid_orders.customer_id,
    paid_orders.order_placed_at,
    paid_orders.order_status,
    paid_orders.total_amount_paid,
    paid_orders.payment_finalized_date,
    customers.customer_first_name,
    customers.customer_last_name,

    -- sales transaction sequence
    row_number() over (order by paid_orders.order_placed_at, paid_orders.order_id) as transaction_seq,

    -- customer sales sequence
    row_number() over (
        partition by paid_orders.customer_id
        order by paid_orders.order_placed_at, paid_orders.order_id
        ) as customer_sales_seq,

    -- new vs returning customer
    case 
      when (
      rank() over (
        partition by paid_orders.customer_id
        order by paid_orders.order_placed_at, paid_orders.order_id
        ) = 1
      ) then 'new'
    else 'return' end as nvsr,

    -- customer lifetime value
    sum(paid_orders.total_amount_paid) over (
      partition by paid_orders.customer_id
      order by paid_orders.order_placed_at, paid_orders.order_id
      ) as customer_lifetime_value,

    -- first day of sale
    first_value(paid_orders.order_placed_at) over (
      partition by paid_orders.customer_id
      order by paid_orders.order_placed_at, paid_orders.order_id
      ) as fdos
    from paid_orders
    left join customers on paid_orders.customer_id = customers.customer_id
)

select * from final
```

And you're done!