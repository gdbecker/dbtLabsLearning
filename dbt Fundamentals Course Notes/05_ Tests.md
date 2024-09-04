## 05_ Tests

### Learning Objectives
- Explain why testing is crucial for analytics.
- Explain the role of testing in analytics engineering.
- Configure and run generic tests in dbt.
- Write, configure, and run singular tests in dbt.

### Review

#### Testing
- Testing is used in software engineering to make sure that the code does what we expect it to.
- In Analytics Engineering, testing allows us to make sure that the SQL transformations we write produce a model that meets our assertions.
- In dbt, tests are written as select statements. These select statements are run against your materialized models to ensure they meet your assertions.

#### Tests in dbt
- In dbt, there are two types of tests - generic tests and singular tests:
  - **Generic tests** are a way to validate your data models and ensure data quality. These tests are predefined and can be applied to any column of your data models to check for common data issues. They are written in YAML files.
  - **Singular tests** are data tests defined by writing specific SQL queries that return records which fail the test conditions. These tests are referred to as "singular" because they are one-off assertions that are uniquely designed for a single purpose or specific scenario within the data models.
- dbt ships with four built in tests: unique, not null, accepted values, relationships.
  - **Unique** tests to see if every value in a column is unique
  - **Not_null** tests to see if every value in a column is not null
  - **Accepted_values** tests to make sure every value in a column is equal to a value in a provided list
  - **Relationships** tests to ensure that every value in a column exists in a column in another model (see: referential integrity)
- Tests can be run against your current project using a range of commands:
  - ```dbt test``` runs all tests in the dbt project
  - ```dbt test --select test_type:generic```
  - ```dbt test --select test_type:singular```
  - ```dbt test --select one_specific_model```
- Read more here in [testing documentation](https://docs.getdbt.com/reference/node-selection/test-selection-examples).
- In development, dbt Cloud will provide a visual for your test results. Each test produces a log that you can view to investigate the test results further.

!["testing dev"](./Pics/05_01%20testing-dev.png)

In production, dbt Cloud can be scheduled to run ```dbt test```. The ‘Run History’ tab provides a similar interface for viewing the test results.

!["testing prod"](./Pics/05_02%20testing-prod.png)

You've learned about the 4 built-in generic tests, but there are so many more tests in packages you could be using! Learn about them in our free online course on [Jinja, Macros, and Packages](https://learn.getdbt.com/courses/jinja-macros-and-packages).

Do you want to take your testing knowledge to the next level? Check out our free online course on [Advanced Testing](https://learn.getdbt.com/courses/advanced-testing)!