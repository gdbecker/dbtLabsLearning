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

#### Some other packages to consider – Python
- [dbt-coverage](https://github.com/slidoapp/dbt-coverage)
  - [Compute](https://github.com/slidoapp/dbt-coverage#compute) coverage from [catalog.json](https://docs.getdbt.com/reference/artifacts/catalog-json) and [manifest.json](https://docs.getdbt.com/reference/artifacts/manifest-json) files found in a dbt project, e.g. jaffle_shop.
- [pre-commit-dbt](https://github.com/dbt-checkpoint/dbt-checkpoint)
  - A comprehensive list of hooks to ensure the quality of your dbt projects.
  - check-model-has-tests: Check the model has a number of tests.
  - check-source-has-tests-by-name: Check the source has a number of tests by test name.
  - See [Enforcing rules at scale with pre-commit-dbt](https://docs.getdbt.com/blog/enforcing-rules-pre-commit-dbt)

#### Some other packages to consider – dbt Packages
- [dbt_dataquality](http://com.getdbt.hub.s3-website-us-east-1.amazonaws.com/Divergent-Insights/dbt_dataquality/latest/)
  - Access and report on the outputs from dbt source freshness ([sources.json](https://docs.getdbt.com/reference/artifacts/sources-json) and [manifest.json](https://docs.getdbt.com/reference/artifacts/manifest-json)) and dbt test ([run_results.json](https://docs.getdbt.com/reference/artifacts/run-results-json) and [manifest.json](https://docs.getdbt.com/reference/artifacts/manifest-json))
  - Optionally tag tests and visualize quality by type
- [dbt-project-evaluator](https://docs.getdbt.com/reference/artifacts/manifest-json)
  - This package highlights areas of a dbt project that are misaligned with dbt Labs' best practices. Specifically, this package tests for:
  - This package is in its early stages!