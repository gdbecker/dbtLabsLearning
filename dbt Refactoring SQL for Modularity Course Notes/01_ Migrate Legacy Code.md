## 01_ Migrate Legacy Code

1. In your dbt project, under your `models` folder, create a subfolder called `legacy`.

2. Within the legacy folder, create a file called `customer_orders.sql`

3. Paste the following query in the `customer_orders.sql` file:

```sql
WITH paid_orders as (select Orders.ID as order_id,
        Orders.USER_ID    as customer_id,
        Orders.ORDER_DATE AS order_placed_at,
            Orders.STATUS AS order_status,
        p.total_amount_paid,
        p.payment_finalized_date,
        C.FIRST_NAME    as customer_first_name,
            C.LAST_NAME as customer_last_name
    FROM raw.jaffle_shop.orders as Orders
    left join (select ORDERID as order_id, max(CREATED) as payment_finalized_date, sum(AMOUNT) / 100.0 as total_amount_paid
from raw.stripe.payment
where STATUS <> 'fail'
group by 1) p ON orders.ID = p.order_id
left join raw.jaffle_shop.customers C on orders.USER_ID = C.ID ),

customer_orders 
    as (select C.ID as customer_id
        , min(ORDER_DATE) as first_order_date
        , max(ORDER_DATE) as most_recent_order_date
        , count(ORDERS.ID) AS number_of_orders
    from raw.jaffle_shop.customers C 
    left join raw.jaffle_shop.orders as Orders
    on orders.USER_ID = C.ID 
    group by 1)

select
    p.*,
    ROW_NUMBER() OVER (ORDER BY p.order_id) as transaction_seq,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY p.order_id) as customer_sales_seq,
    CASE WHEN c.first_order_date = p.order_placed_at
    THEN 'new'
    ELSE 'return' END as nvsr,
    x.clv_bad as customer_lifetime_value,
    c.first_order_date as fdos
    FROM paid_orders p
    left join customer_orders as c USING (customer_id)
    LEFT OUTER JOIN 
    (
            select
            p.order_id,
            sum(t2.total_amount_paid) as clv_bad
        from paid_orders p
        left join paid_orders t2 on p.customer_id = t2.customer_id and p.order_id >= t2.order_id
        group by 1
        order by p.order_id
    ) x on x.order_id = p.order_id
    ORDER BY order_id
```

4. Conduct a `dbt run -m customer_orders` to ensure your model is built in the warehouse. You should see this model under `{your development schema}.customer_orders` (i.e, `dbt_pkearns.customer_orders`)

5. In your dbt project, under your `models` folder, create a subfolder called `marts`.

6. Within the legacy folder, create a file called `fct_customer_orders.sql`

Paste the following query in the `fct_customer_orders.sql` file:

```sql
WITH paid_orders as (select Orders.ID as order_id,
        Orders.USER_ID    as customer_id,
        Orders.ORDER_DATE AS order_placed_at,
            Orders.STATUS AS order_status,
        p.total_amount_paid,
        p.payment_finalized_date,
        C.FIRST_NAME    as customer_first_name,
            C.LAST_NAME as customer_last_name
    FROM raw.jaffle_shop.orders as Orders
    left join (select ORDERID as order_id, max(CREATED) as payment_finalized_date, sum(AMOUNT) / 100.0 as total_amount_paid
from raw.stripe.payment
where STATUS <> 'fail'
group by 1) p ON orders.ID = p.order_id
left join raw.jaffle_shop.customers C on orders.USER_ID = C.ID ),

customer_orders 
    as (select C.ID as customer_id
        , min(ORDER_DATE) as first_order_date
        , max(ORDER_DATE) as most_recent_order_date
        , count(ORDERS.ID) AS number_of_orders
    from raw.jaffle_shop.customers C 
    left join raw.jaffle_shop.orders as Orders
    on orders.USER_ID = C.ID 
    group by 1)

select
    p.*,
    ROW_NUMBER() OVER (ORDER BY p.order_id) as transaction_seq,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY p.order_id) as customer_sales_seq,
    CASE WHEN c.first_order_date = p.order_placed_at
    THEN 'new'
    ELSE 'return' END as nvsr,
    x.clv_bad as customer_lifetime_value,
    c.first_order_date as fdos
    FROM paid_orders p
    left join customer_orders as c USING (customer_id)
    LEFT OUTER JOIN 
    (
            select
            p.order_id,
            sum(t2.total_amount_paid) as clv_bad
        from paid_orders p
        left join paid_orders t2 on p.customer_id = t2.customer_id and p.order_id >= t2.order_id
        group by 1
        order by p.order_id
    ) x on x.order_id = p.order_id
    ORDER BY order_id
```

7. Conduct a `dbt run -m fct_customer_orders` to ensure your model is built in the warehouse. You should see this model under `{your development schema}.fct_customer_orders` (i.e, `dbt_pkearns.fct_customer_orders`)

8. In your project, in the root folder, create a file `packages.yml`

Paste the following into the `packages.yml` file:

```yml
packages:
  - package: dbt-labs/audit_helper
    version: 0.4.0
```

9. Run `dbt deps` in the command line

10. Within the analysis folder, add a new file: `compare_queries.sql`

Paste the following into the `compare_queries.sql` file:

```sql
{% set old_etl_relation=ref('customer_orders') %} 

{% set dbt_relation=ref('fct_customer_orders') %}  {{ 

audit_helper.compare_relations(
        a_relation=old_etl_relation,
        b_relation=dbt_relation,
        primary_key="order_id"
    ) }}
```

11. Hit the `Preview` button:

You will see 1 line output showing 100% match between the two files, because they are exactly the same! You can run the steps (`dbt run` followed by `preview` in `compare_queries.sql`) to ensure any changes you make to the `fct_customer_orders.sql` file does not have unintended consequences causing a drift between the old and new versions.