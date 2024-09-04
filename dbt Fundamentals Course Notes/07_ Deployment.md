## 07_ Deployment

### Learning Objectives
- Understand why it's necessary to deploy your project.
- Explain the purpose of creating a deployment environment.
- Schedule a job in dbt Cloud.
- Review the results and artifacts of a scheduled job in dbt Cloud.

### Review

#### Development vs. Deployment
- Development in dbt is the process of building, refactoring, and organizing different files in your dbt project. This is done in a development environment using a development schema (`dbt_jsmith`) and typically on a non-default branch (i.e. feature/customers-model, fix/date-spine-issue). After making the appropriate changes, the development branch is merged to main/master so that those changes can be used in deployment.
- Deployment in dbt (or running dbt in production) is the process of running dbt on a schedule in a deployment environment. The deployment environment will typically run from the default branch (i.e., main, master) and use a dedicated deployment schema (e.g., `dbt_prod`). The models built in deployment are then used to power dashboards, reporting, and other key business decision-making processes.
- The use of development environments and branches makes it possible to continue to build your dbt project without affecting the models, tests, and documentation that are running in production.

#### Creating your Deployment Environment
- A deployment environment can be configured in dbt Cloud on the Environments page.
- **General Settings**: You can configure which dbt version you want to use and you have the option to specify a branch other than the default branch.
- **Data Warehouse Connection**: You can set data warehouse specific configurations here. For example, you may choose to use a dedicated warehouse for your production runs in Snowflake.
- **Deployment Credentials**: Here is where you enter the credentials dbt will use to access your data warehouse:
  - IMPORTANT: When deploying a real dbt Project, you should set up a **separate data warehouse account** for this run. This should not be the same account that you personally use in development.
  - IMPORTANT: The schema used in production should be **different** from anyone's development schema.

#### Scheduling a job in dbt Cloud
- Scheduling of future jobs can be configured in dbt Cloud on the Jobs page.
- You can select the deployment environment that you created before or a different environment if needed.
- **Commands**: A single job can run multiple dbt commands. For example, you can run ```dbt run``` and ```dbt test``` back to back on a schedule. You don't need to configure these as separate jobs.
- **Triggers**: This section is where the schedule can be set for the particular job.
- After a job has been created, you can manually start the job by selecting ```Run Now```

#### Reviewing Cloud Jobs
- The results of a particular job run can be reviewed as the job completes and over time.
- The logs for each command can be reviewed.
- If documentation was generated, this can be viewed.
- If ```dbt source freshness``` was run, the results can also be viewed at the end of a job.

Curious to know more about deploying with dbt Cloud? Check out our free online [Advanced Deployment course](https://learn.getdbt.com/courses/advanced-deployment), where you'll learn how to deploy your dbt Cloud project with advanced functionality including continuous integration, orchestrating conflicting jobs, and customizing behavior by environment!

Want to know how to automate and accelerate your dbt workflow? Learn how with our free online course on [Webhooks](https://learn.getdbt.com/courses/webhooks)!