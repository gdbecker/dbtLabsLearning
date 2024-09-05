## 03_ Custom Testing

### Learning Objectives
- Write and execute a singular test in your dbt project (overlap from dbt fundamentals)
- Promote a singular test to a reusable generic test
- Override an existing test in the dbt global project or a package

### Review

#### Singular tests
A singular test is a SQL SELECT statement that makes an assertion in reference to a specific model and its specific columns. Singular tests are sql files that live in the tests folder and use the ref function to call a specific model. 

!["1"](./Pics/03_01%201667495553257.png)

```sql
-- This is a singular test designed to test that the average of a returning customer's order is greater than or equal to one. 
{{ config(enabled = false) }}

select
    customer_id, 
    avg(amount) as average_amount
from {{ ref('orders') }}
group by 1
having count(customer_id) > 1 and average_amount < 1
```

#### Custom generic tests
We can promote **singular tests** to **generic tests**, a function built in SQL and Jinja, that utilizes input parameters, like a macro. Rather than a Jinja macro tag, generic tests use a test tag, and we store the generic test in the tests/generic folder. Custom generic tests make it easy to add testing logic in one place and apply it to several models.

```sql
{% test average_dollars_spent_greater_than_one( model, column_name, group_by_column) %}

select 
    {{ group_by_column }},
    avg( {{ column_name }} ) as average_amount

from {{ model }}
group by 1
having average_amount < 1


{% endtest %}
```

#### Overwriting native tests
We can overwrite native tests by creating a generic test with the exact same name as the native test (unique, not_null, relationships, acccepted_values). You can put your new version in the tests/generic/subdirectory, and rebuild the test block with your own SQL. dbt will then use your specified test rather than the native version. 
- Note: Before you run off and customize the native tests, be sure to learn about test configurations later in the course!

### Resources
- [Writing custom generic tests](https://docs.getdbt.com/best-practices/writing-custom-generic-tests)
- [Test configurations ](https://docs.getdbt.com/reference/data-test-configs#test-specific-configurations)