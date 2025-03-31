## 01_ Intro to Advanced Deployment

### Learning Objectives
- Explain the difference between deployment and development environments in dbt
- Explain the pro’s and con’s of the two most common deployment architectures
- Setup and configure deployment environments for QA and production environments

### Review

#### Environments, jobs, and runs
**Environments** encompass a collection of settings for how you want to run your dbt project. This includes:
- dbt version
- git branch
- data location (target schema)
- 
The **development environment** applies the same settings for all developers working in dbt Cloud. **Deployment environments** can be set up to support various different deployment strategies and architectures (more on that later in the course.)

**Jobs** are a set of dbt commands that you run within an environment. This can include commands like `dbt build` with any selection syntax / flags that you may want. These jobs can then be kicked off through a variety of means covered in the rest of this course.

**Runs** are the implementation of a specific job that you have configured that was triggered. While a job is running, you can see that status of that job in real time. Once the job is finished, you can see the run results and view artifacts from that particular run.

#### Scheduling options in dbt Cloud
There are 3 major ways to trigger a job in dbt Cloud:
1. **Schedule** - you can configure a schedule for a job to run directly within the dbt Cloud UI. You can set this through a user friendly UI or in a more customizable way with cron syntax.
2. **Webhook** - you can trigger a job with a webhook from your git provider. Currently dbt Cloud supports GitHub, Gitlab, and Azure Devops.
3. **API Call** - If you are using an external orchestrator such as Airflow, you can call dbt Cloud directly to initiate an job through an API call. This will require either a service token or user token.

#### Reviewing past runs
When a run completes, you can view several things about that particular run
- Model timing
- Run logs
- Artifacts including json files and compiled SQL
- Documentation (if configured)
- Source freshness (if configured)

#### Coordinating different jobs
There are cases where you may have jobs that run concurrently on shared models. In these cases, you likely want to account for those conflicts. This can be difficult to achieve with the user friendly scheduling options. To avoid these conflict, consider using cron syntax or API calls to avoid the overlapping jobs.

#### Related resources
- [dbt guides: Airflow and dbt Cloud](https://docs.getdbt.com/guides/airflow-and-dbt-cloud?step=1)
- [dbt docs: Environments](https://docs.getdbt.com/docs/environments-in-dbt)