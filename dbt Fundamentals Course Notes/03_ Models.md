## 03_ Models

### Learning Objestives
- Explain what models are in a dbt project.
- Build your first dbt model.
- Explain how to apply modularity to analytics with dbt.
- Modularize your project with the ref function.
- Review a brief history of modeling paradigms.
- Identify common naming conventions for tables.
- Reorganize your project with subfolders.

### Review

#### Models
- Models are .sql files that live in the models folder.
- Models are simply written as select statements - there is no DDL/DML that needs to be written around this. This allows the developer to focus on the logic.
- In the Cloud IDE, the Preview button will run this select statement against your data warehouse. The results shown here are equivalent to what this model will return once it is materialized.
- After constructing a model, dbt run in the command line will actually materialize the models into the data warehouse. The default materialization is a view.
- The materialization can be configured as a table with the following configuration block at the top of the model file:

```dbt
{{ config(
materialized='table'
) }}
```

- The same applies for configuring a model as a view:

```dbt
{{ config(
materialized='view'
) }}
```

- When ```dbt run``` is executing, dbt is wrapping the select statement in the correct DDL/DML to build that model as a table/view. If that model already exists in the data warehouse, dbt will automatically drop that table or view before building the new database object. *Note: If you are on BigQuery, you may need to run ```dbt run --full-refresh``` for this to take effect.
- The DDL/DML that is being run to build each model can be viewed in the logs through the cloud interface or the target folder.

!["cloud run logs"](./Pics/03_01%20cloud_run_logs.png)

#### Modularity
- We could build each of our final models in a single model as we did with dim_customers, however with dbt we can create our final data products using modularity.
- Modularity is the degree to which a system's components may be separated and recombined, often with the benefit of flexibility and variety in use.
- This allows us to build data artifacts in logical steps.
- For example, we can stage the raw customers and orders data to shape it into what we want it to look like. Then we can build a model that references both of these to build the final dim_customers model.
- Thinking modularly is how software engineers build applications. Models can be leveraged to apply this modular thinking to analytics engineering.

#### ref Macro
- Models can be written to reference the underlying tables and views that were building the data warehouse (e.g. ```analytics.dbt_jsmith.stg_jaffle_shop_customers```). This hard codes the table names and makes it difficult to share code between developers.
- The ```ref``` function allows us to build dependencies between models in a flexible way that can be shared in a common code base. The ```ref``` function compiles to the name of the database object as it has been created on the most recent execution of ```dbt run``` in the particular development environment. This is determined by the environment configuration that was set up when the project was created.
- Example: ```{{ ref('stg_jaffle_shop_customers') }}``` compiles to ```analytics.dbt_jsmith.stg_jaffle_shop_customers```.
- The ```ref``` function also builds a lineage graph like the one shown below. dbt is able to determine dependencies between models and takes those into account to build models in the correct order.

!["DAG"](./Pics/03_02%20827ep5d0uzar-DAG.jpg)

#### Modeling History
- There have been multiple modeling paradigms since the advent of database technology. Many of these are classified as normalized modeling.
- Normalized modeling techniques were designed when storage was expensive and computational power was not as affordable as it is today.
- With a modern cloud-based data warehouse, we can approach analytics differently in an agile or ad hoc modeling technique. This is often referred to as denormalized modeling.
- dbt can build your data warehouse into any of these schemas. dbt is a tool for how to build these rather than enforcing what to build.

#### Naming Conventions 

In working on this project, we established some conventions for naming our models.
- Sources (```src```) refer to the raw table data that have been built in the warehouse through a loading process. (We will cover configuring Sources in the Sources module)
- Staging (```stg```) refers to models that are built directly on top of sources. These have a one-to-one relationship with sources tables. These are used for very light transformations that shape the data into what you want it to be. These models are used to clean and standardize the data before transforming data downstream. Note: These are typically materialized as views.
- Intermediate (```int```) refers to any models that exist between final fact and dimension tables. These should be built on staging models rather than directly on sources to leverage the data cleaning that was done in staging.
- Fact (```fct```) refers to any data that represents something that occurred or is occurring. Examples include sessions, transactions, orders, stories, votes. These are typically skinny, long tables.
- Dimension (```dim```) refers to data that represents a person, place or thing. Examples include customers, products, candidates, buildings, employees.
- Note: The Fact and Dimension convention is based on previous normalized modeling techniques.

#### Reorganize Project
- When ```dbt run``` is executed, dbt will automatically run every model in the models directory.
- The subfolder structure within the models directory can be leveraged for organizing the project as the data team sees fit.
- This can then be leveraged to select certain folders with ```dbt run``` and the model selector.
- Example: If ```dbt run -s staging``` will run all models that exist in ```models/staging```. (Note: This can also be applied for ```dbt test``` as well which will be covered later.)
- The following framework can be a starting part for designing your own model organization:
- **Marts** folder: All intermediate, fact, and dimension models can be stored here. Further subfolders can be used to separate data by business function (e.g. marketing, finance)
**Staging** folder: All staging models and source configurations can be stored here. Further subfolders can be used to separate data by data source (e.g. Stripe, Segment, Salesforce). (We will cover configuring Sources in the Sources module)

!["Directory"](./Pics/03_03%20ypi962x0mo0f-Directory.jpg)