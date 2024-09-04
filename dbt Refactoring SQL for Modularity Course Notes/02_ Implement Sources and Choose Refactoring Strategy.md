## 02_ Implement Sources and Choose Refactoring Strategy

1. Create a subfolder under your `models` folder called stag`ing.

2. Under your `models > staging` folder, create two subfolders - one for each source schema that our original query pulls from. These subfolders are `stripe` and `jaffle_shop`.

3. Create a file under `models > staging > jaffle_shop` called `sources.yml`.

4. Create a file under `models > staging > stripe` called `sources.yml`.

5. [Declare configurations for the corresponding source](https://docs.getdbt.com/docs/build/sources#declaring-a-source) in each file:

**models/staging/jaffle_shop/sources.yml**
```yml
version: 2

sources:
  - name: jaffle_shop
    database: raw
    tables:
      - name: customers
      - name: orders
```

**models/staging/stripe/sources.yml**
```yml
version: 2

sources:
  - name: stripe
    database: raw
    tables:
      - name: payments
```

6. Now that your sources are configured, open your `fct_customer_orders.sql` file and replace any hardcoded references (i.e, `raw.jaffle_shop.customers`) with a [source function](https://docs.getdbt.com/docs/build/sources#selecting-from-a-source), referencing the sources you have set up.

```sql
with 
    paid_orders as (
        select orders.id as order_id,
            orders.user_id as customer_id,
            orders.order_date as order_placed_at,
            orders.status as order_status,
            p.total_amount_paid,
            p.payment_finalized_date,
            c.first_name as customer_first_name,
            c.last_name as customer_last_name
        from {{ source('jaffle_shop', 'orders') }} as orders
        left join (
            select 
                orderid as order_id,
                max(created) as payment_finalized_date,
                sum(amount) / 100.0 as total_amount_paid
            from {{ source('stripe', 'payment') }} as payments
            where status <> 'fail'
            group by 1
        ) p on orders.id = p.order_id
        left join {{ source('jaffle_shop', 'customers') }} as c on orders.user_id = c.id ),

    customer_orders as (
        select 
            c.id as customer_id
            , min(order_date) as first_order_date
            , max(order_date) as most_recent_order_date
            , count(orders.id) as number_of_orders
        from {{ source('jaffle_shop', 'customers') }}  c 
        left join {{ source('jaffle_shop', 'orders') }}  as orders on orders.user_id = c.id 
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

7. Conduct a `dbt run -m fct_customer_orders` to ensure that your sources are configured properly and your model rebuilds in the warehouse.

8. Run `dbt docs generate` and click on the highlighted `view docs` text when this is done - open your DAG in the subsequent window by clicking on the icon in the bottom right hand corner:

!["dag button"](./Pics/02_01%20dag_button.png)

Inspect your DAG!

!["step 2"](./Pics/02_02%20step_2_dag.png)