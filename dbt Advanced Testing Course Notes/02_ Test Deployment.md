## 02_ Test Deployment

### Learning Objectives
- Understand when in the life cycle of your project to run different types of tests
- Run tests on subsets of your DAG using node selector syntax and test specific flags
- How to take action on your test failures
- Enable testing to store test failures in the database for record keeping

#### When to test
There are 4 major points in time when you should consider testing your code

1. In **development**, it is critical to test your changes to modeling logic while you make changes. This can help individual developers find bugs before opening a pull request.
2. In **production**, it is important to continue testing your code to catch failures when they happen. This can empower the data team to catch data quality issues well before stakeholders are impacted.
3. When **proposing changes / opening a pull or merge request**, we can run automated tests against our proposed changes to catch any issues that may not have been caught in the development cycle mentioned above.
4. On a **middle / qa branch**, it can be helpful to test a batch of changes that have been made in an isolated testing environment before then merging the code to the main / production branch.

#### Testing commands
There are several ways to run tests against your data in dbt. In development, it likely will make more sense to write a model and materialize it with `dbt run` and then test your models with `dbt test`. However, once you are materializing and testing multiple models at once, we highly recommend running `dbt build` to materialize and test all nodes in DAG order.

#### Storing test failures in the database
When you are testing your models in production or development, it can be helpful to capture the failing records for future inspection. The `store_failures` configuration or command line flag allows you to store these failures in the database for further analysis.

#### Packages
There are three packages that are must-haves for any dbt project: dbt_utils, dbt_expectations, and audit_helper. Here are the steps to use any package:

1. Import the package that you want in your packages.yml file
2. Run `dbt deps`
3. Add the name of the package and the name of the test to your .yml file

#### dbt_utils
dbt_utils is a one-stop-shop for several key functions and tests that you’ll use every day in your project.

Here are some useful tests in [dbt_utils](https://hub.getdbt.com/dbt-labs/dbt_utils/latest/):
- expression_is_true
- cardinality_equality
- unique_where
- not_null_where
- not_null_proportion
- unique_combination_of_columns

#### dbt_expectations
dbt_expectations contains a large number of tests that you may not find native to dbt or dbt_utils. If you are familiar with Python’s great_expectations, this package might be for you!

Here are some useful tests in [dbt_expectations](https://hub.getdbt.com/calogica/dbt_expectations/latest/):
- expect_column_values_to_be_between
- expect_row_values_to_have_data_for_every_n_datepart
- expect_column_values_to_be_within_n_moving_stdevs
- expect_column_median_to_be_between
- expect_column_values_to_match_regex_list
- expect_column_values_to_be_increasing

#### audit_helper
This package is utilized when you are making significant changes to your models, and you want to be sure the updates do not change the resulting data. The audit helper functions will only be run in the IDE, rather than a test performed in deployment.

Here are some useful tools in [audit_helper](https://hub.getdbt.com/dbt-labs/audit_helper/latest/):
- compare_relations
- compare_queries
- compare_column_values
- compare_relation_columns
- compare_all_columns
- compare_column_values_verbose

#### Related resources
- [dbt Developer Blog: Enforcing rules at scale with pre-commit-dbt](https://docs.getdbt.com/blog/enforcing-rules-pre-commit-dbt)
- [Package Hub](https://hub.getdbt.com/)
- [dbt_utils](https://hub.getdbt.com/dbt-labs/dbt_utils/latest/)
- [dbt_expectations](https://hub.getdbt.com/calogica/dbt_expectations/latest/)
- [audit_helper](https://hub.getdbt.com/dbt-labs/audit_helper/latest/)