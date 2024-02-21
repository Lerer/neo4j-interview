## Neo4j Assignment

This repositoty holds the assignment implelmentation for Neo4j.

The repository is structured as:

- `NEO4J_EXERCISE_FILES` Folder - contains the `csv` input data files mainly as a web reference as the Neo4j load script is referencing these files
- `scripts` Folder - Exercise implementation files as follow:
  - `clean.cypher` - a cypher script to clean the Neo4j DB Instance
  - `build.cypher` - a script to load the data from the `.csv` files which reside inside the`NEO4J_EXERCISE_FILES` folder
  - `queries.cypher` - a script which contains the different queries as requested in the exercise guide

> Note - For the execution of the above scripts, I used the fully-managed cloud service for Neo4j - [**neo4j auraDB**](https://neo4j.com/cloud/platform/aura-graph-database/)
