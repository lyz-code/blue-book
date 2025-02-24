---
title: Aleph
date: 20221116
author: Lyz
---

[Aleph](https://github.com/alephdata/aleph) is a tool for indexing large amounts
of both documents (PDF, Word, HTML) and structured (CSV, XLS, SQL) data for easy
browsing and search. It is built with investigative reporting as a primary use
case. Aleph allows cross-referencing mentions of well-known entities (such as
people and companies) against watchlists, e.g. from prior research or public
datasets.

# Usage
## [API Usage](https://redocly.github.io/redoc/?url=https://aleph.occrp.org/api/openapi.json)

The Aleph web interface is powered by a Flask HTTP API. Aleph supports an extensive API for searching documents and entities. It can also be used to retrieve raw metadata, source documents and other useful details. Aleph's API tries to follow a pragmatic approach based on the following principles:

- All API calls are prefixed with an API version; this version is /api/2/.
- Responses and requests are both encoded as JSON. Requests should have the Content-Type and Accept headers set to application/json.
- The application uses Representational State Transfer (REST) principles where convenient, but also has some procedural API calls.
- The API allows API Authorization via an API key or JSON Web Tokens.

### [Authentication and authorization](https://redocly.github.io/redoc/?url=https://aleph.occrp.org/api/openapi.json#section/Authentication-and-Authorization)

By default, any Aleph search will return only public documents in responses to API requests.

If you want to access documents which are not marked public, you will need to sign into the tool. This can be done through the use on an API key. The API key for any account can be found by clicking on the "Settings" menu item in the navigation menu.

The API key must be sent on all queries using the Authorization HTTP header:

```
Authorization: ApiKey 363af1e2b03b41c6b3adc604956e2f66
```

Alternatively, the API key can also be sent as a query parameter under the api_key key.

Similarly, a JWT can be sent in the Authorization header, after it has been returned by the login and/or OAuth processes. Aleph does not use session cookies or any other type of stateful API.


## Crossreferencing mentions with entities

[Mentions](https://docs.aleph.occrp.org/developers/explanation/cross-referencing/#mentions) are names of people or companies that Aleph automatically extracts from files you upload. Aleph includes mentions when cross-referencing a collection, but only in one direction.

Consider the following example:

- "Collection A" contains a file. The file mentions "John Doe".
- "Collection B" contains a Person entity named "John Doe".

If you cross-reference “Collection A”, Aleph includes the mention of “John Doe” in the cross-referencing and will find a match for it in “Collection B”.

However, if you cross-reference “Collection B”, Aleph doesn't consider mentions when trying to find a match for the Person entity.

As long as you only want to compare the mentions in one specific collection against entities (but not mentions) in another collection, Aleph’s cross-ref should be able to do that. If you want to compare entities in a specific collection against other entities and mentions in other collections, you will have to do that yourself.

If you have a limited number of collection, one option might be to fetch all mentions and automatically create entities for each mention using the API.

To fetch a list of mentions for a collection you can use the `/api/2/entities?filter:collection_id=137&filter:schemata=Mention` API request.

## Get all documents of a collection

`list_aleph_collection_documents.py` is a Python script designed to interact with an API to 
retrieve and analyze documents from specified collections. It offers a command-line interface 
(CLI) to list and check documents within a specified collection.

### Features

- Retrieve documents from a specified collection.
- Analyze document processing statuses and warn if any are not marked as successful.
- Return a list of filenames from the retrieved documents.
- Supports verbose output for detailed logging.
- Environment variable support for API key management.

### Installation

To install the required dependencies, use `pip`:

```bash
pip install typer requests
```

Ensure you have Python 3.6 or higher installed.

Create the file `list_aleph_collection_documents.py` with the next contents:

```python
import logging
import requests
from typing import List, Dict, Any, Optional
import logging
import typer
from typing import List, Dict, Any


log = logging.getLogger(__name__)
app = typer.Typer()


@app.command()
def get_documents(
    collection_name: str = typer.Argument(...),
    api_key: Optional[str] = typer.Option(None, envvar="API_KEY"),
    base_url: str = typer.Option("https://your.aleph.org"),
    verbose: bool = typer.Option(
        False, "--verbose", "-v", help="Enable verbose output"
    ),
):
    """CLI command to retrieve documents from a specified collection."""
    if verbose:
        logging.basicConfig(level=logging.DEBUG)
        log.debug("Verbose mode enabled.")
    else:
        logging.basicConfig(level=logging.INFO)
    if api_key is None:
        log.error(
            "Please specify your api key either through the --api-key argument "
            "or through the API_KEY environment variable"
        )
        raise typer.Exit(code=1)
    try:
        documents = list_collection_documents(api_key, base_url, collection_name)
        filenames = check_documents(documents)
        if filenames:
            print("\n".join(filenames))
        else:
            log.warning("No documents found.")
    except Exception as e:
        log.error(f"Failed to retrieve documents: {e}")
        raise typer.Exit(code=1)


def list_collection_documents(
    api_key: str, base_url: str, collection_name: str
) -> List[Dict[str, Any]]:
    """
    Retrieve documents from a specified collection using pagination.

    Args:
        api_key (str): The API key for authentication.
        base_url (str): The base URL of the API.
        collection_name (str): The name of the collection to retrieve documents from.

    Returns:
        List[Dict[str, Any]]: A list of documents from the specified collection.

    Example:
        >>> docs = list_collection_documents("your_api_key", "https://api.example.com", "my_collection")
        >>> print(len(docs))
        1000
    """
    headers = {
        "Authorization": f"ApiKey {api_key}",
        "Accept": "application/json",
        "Content-Type": "application/json",
    }

    collections_url = f"{base_url}/api/2/collections"
    documents_url = f"{base_url}/api/2/entities"
    log.debug(f"Requesting collections list from {collections_url}")
    collections = []
    params = {"limit": 300}

    while True:
        response = requests.get(collections_url, headers=headers, params=params)
        response.raise_for_status()
        data = response.json()
        collections.extend(data["results"])
        log.debug(
            f"Fetched {len(data['results'])} collections, "
            f"page {data['page']} of {data['pages']}"
        )
        if not data["next"]:
            break
        params["offset"] = params.get("offset", 0) + data["limit"]

    collection_id = next(
        (c["id"] for c in collections if c["label"] == collection_name), None
    )
    if not collection_id:
        log.error(f"Collection {collection_name} not found.")
        return []

    log.info(f"Found collection '{collection_name}' with ID {collection_id}")

    documents = []
    params = {
        "q": "",
        "filter:collection_id": collection_id,
        "filter:schemata": "Document",
        "limit": 300,
    }

    while True:
        log.debug(f"Requesting documents from collection {collection_id}")
        response = requests.get(documents_url, headers=headers, params=params)
        response.raise_for_status()
        data = response.json()
        documents.extend(data["results"])
        log.info(
            f"Fetched {len(data['results'])} documents, "
            f"page {data['page']} of {data['pages']}"
        )
        if not data["next"]:
            break
        params["offset"] = params.get("offset", 0) + data["limit"]

    log.info(f"Retrieved {len(documents)} documents from collection {collection_name}")

    return documents


def check_documents(documents: List[Dict[str, Any]]) -> List[str]:
    """Analyze the processing status of documents and return a list of filenames.

    Args:
        documents (List[Dict[str, Any]]): A list of documents in JSON format.

    Returns:
        List[str]: A list of filenames from documents with a successful processing status.

    Raises:
        None, but logs warnings if a document's processing status is not 'success'.

    Example:
        >>> docs = [{"properties": {"processingStatus": ["success"], "fileName": ["file1.txt"]}},
        >>>         {"properties": {"processingStatus": ["failed"], "fileName": ["file2.txt"]}}]
        >>> filenames = check_documents(docs)
        >>> print(filenames)
        ['file1.txt']
    """
    filenames = []

    for doc in documents:
        status = doc.get("properties", {}).get("processingStatus")[0]
        filename = doc.get("properties", {}).get("fileName")[0]

        if status != "success":
            log.warning(
                f"Document with filename {filename} has processing status: {status}"
            )

        if filename:
            filenames.append(filename)

    log.debug(f"Collected filenames: {filenames}")
    return filenames


if __name__ == "__main__":
    app()
```

#### Get your API key

By default, any Aleph search will return only public documents in responses to API requests.

If you want to access documents which are not marked public, you will need to sign into the tool. This can be done through the use on an API key. The API key for any account can be found by clicking on the "Settings" menu item in the navigation menu.

### Usage

#### Running the Script

You can run the script directly from the command line. Below are examples of usage:

##### Basic Usage

Retrieve and list documents from a collection:

```bash
python list_aleph_collection_documents.py --api-key "your-api-key" 'Name of your collection'
```

##### Using an Environment Variable for the API Key

This is better from a security perspective.
```bash
export API_KEY=your_api_key
python list_aleph_collection_documents.py 'Name of your collection'
```

##### Enabling Verbose Logging

To enable detailed debug logs, use the `--verbose` or `-v` flag:

```bash
python list_aleph_collection_documents.py -v 'Name of your collection'
```
##### Getting help


```bash
python list_aleph_collection_documents.py --help
```
# [Install the development environment](https://docs.alephdata.org/developers/installation#getting-started)

As a first step, check out the source code of Aleph from GitHub:

```bash
git clone https://github.com/alephdata/aleph.git
cd aleph/
```

Also, please execute the following command to allow ElasticSearch to map its
memory:

```bash
sysctl -w vm.max_map_count=262144
```

Then enable
[the use of `pdb`](https://docs.alephdata.org/developers/installation#debugging)
by adding the next lines into the `docker-compose.dev.yml` file, under the `api`
service configuration.

```yaml
stdin_open: true
tty: true
```

With the settings in place, you can use `make all` to set everything up and
launch the web service. This is equivalent to the following steps:

- `make build` to build the docker images for the application and relevant
  services.
- `make upgrade` to run the latest database migrations and create/update the
  search index.
- `make web` to run the web-based API server and the user interface.
- In a separate shell, run `make worker` to start a worker. If you do not start
  a worker, background jobs (for example ingesting new documents) won’t be
  processed.

Open http://localhost:8080/ in your browser to visit the web frontend.

- Create a shell to do the operations with `make shell`.
- Create the main user within that shell running
  ```bash
  aleph createuser --name="demo" \
      --admin \
      --password=demo \
      demo@demo.com
  ```
- Load some sample data by running `aleph crawldir /aleph/contrib/testdata`

## Debugging the code

To debug the code, you can create `pdb` breakpoints in the code you cloned, and
run the actions that trigger the breakpoint. To be able to act on it, you need
to be attached to the api by running:

```bash
docker attach aleph_api_1
```

You don't need to reload the page for it to load the changes, it does it
dynamically.

## Operation

### [Upgrade Aleph](https://docs.alephdata.org/developers/technical-faq#how-do-i-upgrade-to-a-new-version-of-aleph)

Aleph does not perform updates and database migrations automatically. Once you
have the latest version, you can run the command bellow to upgrade the existing
installation (i.e. apply changes to the database model or the search index
format).

The first step is to add a notice in Aleph's banner section informing the users
that there's going to be a downtime.

Before you upgrade, check the  to make sure you understand the [latest
release](https://docs.alephdata.org/developers/changelog)
and know about new options and features that have been added.

In production mode, make sure you perform a backup of the main database and the
ElasticSearch index before running an upgrade.

Then, make sure you are using the latest `docker-compose.yml` file. You can do
this by checking out [the source repo](https://github.com/alephdata/aleph), but
really you just need that one file (and your config in aleph.env). There are
many `docker-compose.yml` files, we need to decide the one we want to take as
the source of truth.

```bash
# Pull changes
cd /data/config/aleph
docker-compose pull --parallel

# Stop services
service aleph stop

# Do database migrations
docker-compose up -d redis postgres elasticsearch
# Wait a minute or so while services boot up...
# Run upgrade:
docker-compose run --rm shell aleph upgrade

# Start the services
service aleph start
```

### [Create Aleph admins](https://docs.alephdata.org/developers/technical-faq#how-can-i-make-an-admin-user)

Creation of admins depends on how you create users, in our case that we're using
Oauth we need to update the database directly (ugly!). So go into the instance
you want to do the change and run:

```bash
# Create a terminal inside the aleph environment
docker-compose run --rm shell bash

# Connect to the postgres database
# It will ask you for the password, search it in the docker-compose.yaml file
psql postgresql://aleph@postgres/aleph

# Once there you can see which users do have the Admin rights with:
select * from role where is_admin = 't';

# If you want to make another user admin run the next command:
UPDATE role SET is_admin = true WHERE email = 'admin@site.org';
```

You may also need to run `aleph update` afterwards to refresh some cached information.

### Remove a group

There is currently no web interface that allows this operation, you need to interact with the database directly.

```bash
# Create a terminal inside the aleph environment
docker-compose run --rm shell bash

# Connect to the postgres database
# It will ask you for the password, search it in the docker-compose.yaml file
psql postgresql://aleph@postgres/aleph

# List the available groups
select * from role where type = 'group';

# Delete a group.
# Imagine that the id of the group we want to delete is 18
delete from role where id = 18;
```

#### Role permission error

You may encounter the next error:

```
ERROR:  update or delete on table "role" violates foreign key constraint "permission_role_id_fkey" on table "permission"
DETAIL:  Key (id)=(18) is still referenced from table "permission".
```

That means that the group is still used, to find who is using it use:

```sql
select * from permission where role_id = 18;
```

You can check the elements that have the permission by looking at the `collection_id` number, imagine it's `3`, then you can check `your.url.com/investigations/3`.

Once you're sure you can remove that permission, run:

```sql
delete from permission where role_id = 18;
delete from role where id = 18;
```

#### Role membership error

You may encounter the next error:

```
ERROR:  update or delete on table "role" violates foreign key constraint "role_membership_group_id_fkey" on table "role_membership"
DETAIL:  Key (id)=(8) is still referenced from table "role_membership".
```
That means that the group is still used, to find who is using it use:

```sql
select * from role_membership where group_id = 8;
```

If you agree to remove that user from the group use:

```sql
delete from role_membership where group_id = 8;
delete from role where id = 8;
```

## Troubleshooting

### Ingest gets stuck

It looks that Aleph doesn't yet give an easy way to debug it. It can be seen in the next webs:

- [Improve the UX for bulk uploading and processing of large number of files](https://github.com/alephdata/aleph/issues/2124)
- [Document ingestion gets stuck effectively at 100%](https://github.com/alephdata/aleph/issues/1839)
- [Display detailed ingestion status to see if everything is alright and when the collection is ready](https://github.com/alephdata/aleph/discussions/1525)

Some interesting ideas I've extracted while diving into these issues is that:

- You can also upload files using the [`alephclient` python command line tool](https://github.com/alephdata/alephclient)
- Some of the files might fail to be processed without leaving any hint to the uploader or the viewer.
  - This results in an incomplete dataset and the users don't get to know that the dataset is incomplete. This is problematic if the completeness of the dataset is crucial for an investigation.
  - There is no way to upload only the files that failed to be processed without re-uploading the entire set of documents or manually making a list of the failed documents and re-uploading them
  - There is no way for uploaders or Aleph admins to see an overview of processing errors to figure out why some files are failing to be processed without going through docker logs (which is not very user-friendly)
- There was an attempt to [improve the way ingest-files manages the pending tasks](https://github.com/alephdata/aleph/issues/2127), it's merged into the [release/4.0.0](https://github.com/alephdata/ingest-file/tree/release/4.0.0) branch, but it has [not yet arrived `main`](https://github.com/alephdata/ingest-file/pull/423).

There are some tickets that attempt to address these issues on the command line:

- [Allow users to upload/crawl new files only](https://github.com/alephdata/alephclient/issues/34)
- [Check if alephclient crawldir was 100% successful or not](https://github.com/alephdata/alephclient/issues/35)

I think it's interesting either to contribute to `alephclient` to solve those issues or if it's complicated create a small python script to detect which files were not uploaded and try to reindex them and/or open issues that will prevent future ingests to fail.

### Problems accessing redis locally

If you're with the VPN connected, turn it off.

### PDB behaves weird

Sometimes you have two traces at the same time, so each time you run a PDB
command it jumps from pdb trace. Quite confusing. Try to `c` the one you don't
want so that you're left with the one you want. Or put the `pdb` trace in a
conditional that only matches one of both threads.
# Alephclient cli tool

alephclient is a command-line client for Aleph. It can be used to bulk import structured data and files and more via the API, without direct access to the server.
## [Installation](https://docs.aleph.occrp.org/developers/how-to/data/install-alephclient/#how-to-install-the-alephclient-cli)

You can now install `alephclient` using pip although I recommend to use `pipx` instead:

```bash
pipx install alephclient
```

`alephclient` needs to know the URL of the Aleph instance to connect to. For privileged operations (e.g. accessing private datasets or writing data), it also needs your API key. You can find your API key in your user profile in the Aleph UI.

Both settings can be provided by setting the environment variables `ALEPHCLIENT_HOST` and `ALEPHCLIENT_API_KEY`, respectively, or by passing them in with `--host` and `--api-key` options.

```bash
export ALEPHCLIENT_HOST=https://aleph.occrp.org/
export ALEPHCLIENT_API_KEY=YOUR_SECRET_API_KEY
```

You can now start using `alephclient` for example to upload an entire directory to Aleph.

## [Upload an entire directory to Aleph](https://docs.aleph.occrp.org/developers/how-to/data/upload-directory/)
While you can upload multiple files and even entire directories at once via the Aleph UI, using the `alephclient` CLI allows you to upload files in bulk much quicker and more reliable.

Run the following `alephclient` command to upload an entire directory to Aleph:

```bash
alephclient crawldir --foreign-id wikileaks-cable /Users/sunu/data/cable
```

This will upload all files in the directory `/Users/sunu/data/cable` (including its subdirectories) into an investigation with the foreign ID `wikileaks-cable`. If no investigation with this foreign ID exists, a new investigation is created (in theory, but it didn't work for me, so manually create the investigation and then copy it's foreign ID).

If you’d like to import data into an existing investigation and do not know its foreign ID, you can find the foreign ID in the Aleph UI. Navigate to the investigation homepage. The foreign ID is listed in the sidebar on the right.
# Monitorization
## [Prometheus metrics](https://github.com/alephdata/aleph/pull/3216)

Aleph now exposes prometheus metrics on the port 9100.
# Available datasets
OpenSanctions helps investigators find leads, allows companies to manage risk and enables technologists to build data-driven products.

You can check [their datasets](https://www.opensanctions.org/datasets/). 
# Other tools for the ecosystem
## [Investigraph](https://investigativedata.github.io/investigraph/)
investigraph is an ETL framework that allows research teams to build their own data catalog themselves as easily and reproducable as possible. The investigraph framework provides logic for extracting, transforming and loading any data source into followthemoney entities.

For most common data source formats, this process is possible without programming knowledge, by means of an easy yaml specification interface. However, if it turns out that a specific dataset can not be parsed with the built-in logic, a developer can plug in custom python scripts at specific places within the pipeline to fulfill even the most edge cases in data processing.
## [offshore-graph](https://github.com/opensanctions/offshore-graph)

It contains scripts that will merge the OpenSanctions Due Diligence dataset with the ICIJ OffshoreLeaks database in order create a combined graph for analysis.

The result is a Cypher script to load the full graph into the Neo4J database and then browse it using the Linkurious investigation platform.

Based on name-based entity matching between the datasets, an analyst can use this graph to find offshore holdings linked to politically exposed and sanctioned individuals.

As a general alternative, you can easily export and convert entities from an Aleph instance to visualize them in Neo4j or Gephi using the ftm CLI: https://docs.aleph.occrp.org/developers/how-to/data/export-network-graphs/

# Troubleshooting
## Debug ingestion errors
Assuming that you've [set up Loki to ingest your logs](https://github.com/alephdata/aleph/issues/2124) I've so far encountered the next ingest issues:

- `Cannot open image data using Pillow: broken data stream when reading image files`: The log trace that has this message also contains a field `trace_id` which identifies the ingestion process. With that `trace_id` you can get the first log trace with the field `logger = "ingestors.manager"` which will contain the file path in the `message` field. Something similar to `Ingestor [<E('9972oiwobhwefoiwefjsldkfwefa45cf5cb585dc4f1471','path_to_the_file_to_ingest.pdf')>]`
- A traceback with the next string `Failed to process: Could not extract PDF file: FileDataError('cannot open broken document')`: This log trace has the file path in the `message` field. Something similar to `[<E('9972oiwobhwefoiwefjsldkfwefa45cf5cb585dc4f1471','path_to_the_file_to_ingest.pdf')>] Failed to process: Could not extract PDF file: FileDataError('cannot open broken document')`

I thought of making a [python script to automate the files that triggered an error](loki.md#interact-with-loki-through-python), but in the end I extracted the file names manually as they weren't many. 

Once you have the files that triggered the errors, the best way to handle them is to delete them from your investigation and ingest them again.
# References

- [Source](https://github.com/alephdata/aleph)
- [Docs](https://docs.alephdata.org/)
- [Support](https://aleph.discourse.group/)
- [API docs](https://redocly.github.io/redoc/?url=https://aleph.occrp.org/api/openapi.json)
