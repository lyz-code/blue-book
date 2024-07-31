Data orchestration is the process of moving siloed data from multiple storage locations into a centralized repository where it can then be combined, cleaned, and enriched for activation.

Data orchestrators are web applications that make this process easy. The most popular right now are:

- Apache Airflow
- [Kestra](#kestra)
- Prefect

There are several comparison pages:

- [Geek Culture comparison](https://medium.com/geekculture/airflow-vs-prefect-vs-kestra-which-is-best-for-building-advanced-data-pipelines-40cfbddf9697)
- [Kestra's comparison to Airflow](https://kestra.io/vs/airflow)
- [Kestra's comparison to Prefect](https://kestra.io/vs/prefect)

When looking at the return on investment when choosing an orchestration tool, there are several points to consider:

- Time of installation/maintenance
- Time to write pipeline
- Time to execute (performance)

# [Kestra](kestra.md)

Pros:

- Easier to write pipelines
- Nice looking web UI
- It has a [terraform provider](https://kestra.io/docs/getting-started/terraform)
- [Prometheus and grafana integration](https://kestra.io/docs/how-to-guides/monitoring)

Cons:

- Built in Java, so extending it might be difficult
- [Plugins are made in Java](https://kestra.io/docs/developer-guide/plugins)

Kestra offers a higher ROI globally compared to Airflow:

- Installing Kestra is easier than Airflow; it doesn’t require Python dependencies, and it comes with a ready-to-use docker-compose file using few services and without the need to understand what’s an executor to run task in parallel.
- Creating pipelines with Kestra is simple, thanks to its syntax. You don’t need knowledge of a specific programming language because Kestra is designed to be agnostic. The declarative YAML design makes Kestra flows more readable compared to Airflow’s DAG equivalent, allowing developers to significantly reduce development time.
- In this benchmark, Kestra demonstrates better execution time than Airflow under any configuration setup.
