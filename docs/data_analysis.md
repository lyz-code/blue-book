
# Tools
- [sq](https://sq.io/):  is a free/libre open-source data wrangling swiss-army knife to inspect, query, join, import, and export data. You could think of sq as jq for databases and documents, facilitating one-liners like:

  ```bash
  sq '@postgres_db | .actor | .first_name, .last_name | .[0:5]'
  ```
