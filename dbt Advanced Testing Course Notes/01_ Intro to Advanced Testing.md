## 01_ Intro to Advanced Testing

### Learning Objectives
- Explain the types of testing that are possible in dbt
- Explain what makes a good test
- Explain what to test and why
- Ensure proper test coverage with `dbt_meta_testing` package

### Review

#### Testing techniques
Testing is used in software engineering to make sure that the code does what we expect it to. In Analytics Engineering, testing allows us to make sure that the SQL transformations we write produce a model that meets our assertions. In dbt, tests are compiled to select statements. These select statements are run against your materialized models to ensure they meet your assertions.

We should test in **development** by testing the models we build using `dbt test` or `dbt build`. In **deployment**, we can create jobs with these same commands to run tests on a schedule. Testing should be **automated**, **fast**, **reliable**, **informative**, and **focused**.

#### What to test and why
There are four key use cases for testing:

1. Tests on **one database object** can be what should be contained within the columns, what should be the constraints of the table, or simply what is the grain.
2. Test **how one database object refers to another database object** by checking data in one table and comparing it to another table that is either a source of truth or is less modified, has less joins, or is less likely to become infected with bad data.
3. Test **something unique about your data** like specific business logic. We can create singular tests using a simple SQL select statement and apply this to one particular model.
4. Test the **freshness of your raw source data** (pipeline tests) to ensure our models don’t run on stale data.

#### Test coverage
Establish norms in your company for what to test and when to test. Codify these norms using the [package: `dbt_meta_testing`](https://hub.getdbt.com/tnightengale/dbt_meta_testing/latest/) to ensure each object has the required tests.