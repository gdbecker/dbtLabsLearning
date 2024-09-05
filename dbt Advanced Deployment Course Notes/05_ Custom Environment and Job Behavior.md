## 05_ Custom Environment and Job Behavior

### Learning Objectives
- Explain why you may want dbt to act differently in different environments
- Explain how environment variables are used and hierarchy
- Explain the jinja target variable and how name can be used
- Leverage target.name to xxx (robust for cloud and core)
- Leverage environment variables to xxx (only supported with cloud)

### Review

#### Customizing behavior in dbt Cloud
There will be cases where you want to have dbt behave differently between environments. Within the dbt context there are two key variables for achieving this:
- **target variable** - the target variable can be set on the job or environment level. This can then be included in your dbt project to tweak the logic dbt handles based on your environment.
- **environment variable** - environment variables are set on the environment level and can be referenced in your dbt Cloud project to modify the behavior of dbt. Environment variables also support secrets in case you need to leverage variables that should not be exposed throughout the logs or the UI.

#### Related resources
- [dbt docs: Environment variables](https://docs.getdbt.com/docs/build/environment-variables)