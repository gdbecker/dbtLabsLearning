## 01_ Materializations

### Learning Objectives
- Explain the five main types of materializations in dbt.
- Configure materializations in configuration files and in models.
- Explain the differences and tradeoffs between tables, views, and ephemeral models.
- Build intuition for incremental models.
- Build intuition for snapshots.

### Review

#### Tables
- Built as tables in the database
- Data is stored on disk
- Slower to build
- Faster to query
- Configure in dbt_project.yml or with the following config block

```sql
{{ config(
    materialized='table'
)}}
```

#### Views
- Built as views in the database
- Query is stored on disk
- Faster to build
- Slower to query
- Configure in dbt_project.yml or with the following config block

```sql
{{ config(
    materialized='view'
)}}
```

#### Ephemeral Models
- Does not exist in the database
- Imported as CTE into downstream models
- Increases build time of downstream models
- Cannot query directly
- [Ephemeral Documentation](https://docs.getdbt.com/docs/build/materializations#ephemeral)
- Configure in dbt_project.yml or with the following config block

```sql
{{ config(
    materialized='ephemeral'
)}}
```

#### Incremental Models 
- Built as table in the database
- On the first run, builds entire table
- On subsequent runs, only appends new records*
- Faster to build because you are only adding new records
- Does not capture 100% of the data all the time
- [Incremental Documentation](https://docs.getdbt.com/docs/build/materializations#incremental)
- [Discourse post on Incrementality](https://discourse.getdbt.com/t/on-the-limits-of-incrementality/303)
0 Configuration is more advanced in this case. Consult the dbt documentation for building your first incremental model.

#### Snapshots
- Built as a table in the database, usually in a dedicated schema.
- On the first run, builds entire table and adds four columns: `dbt_scd_id`, `dbt_updated_at`, `dbt_valid_from`, and `dbt_valid_to`
- In future runs, dbt will scan the underlying data and append new records based on the configuration that is made.
- This allows you to capture historical data
- [Snapshots Documentation](https://docs.getdbt.com/docs/build/snapshots)
Configuration is more advanced in this case. Consult the dbt documentation for writing your first snapshot.

#### Help on Setting Up Snowplow with BigQuery in dbt Cloud IDE
- [snowplow_web dbt package](https://hub.getdbt.com/snowplow/snowplow_web/latest/)
  - Use this one instead of the one from dbt-labs
- [Snowplow configuration options](https://docs.snowplow.io/docs/modeling-your-data/modeling-your-data-with-dbt/dbt-configuration/legacy/web/)
  - I copied/pasted the yml config info from the bottom of the page
- [Quickstart for getting things running](https://docs.snowplow.io/docs/modeling-your-data/modeling-your-data-with-dbt/dbt-quickstart/legacy/web/)

I was blocked from finishing due to BigQuery's free tier limit on not using DML statements, like changing a table to be incremental