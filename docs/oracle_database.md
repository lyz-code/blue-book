---
title: Oracle Database
date: 20210730
author: Lyz
---

Oracle Database is an awful proprietary database, run away from it!

# [Install](https://dzone.com/articles/create-an-oracle-database-docker-image)

* Download or clone the files of [their docker
    repository](https://github.com/oracle/docker-images/).
* Create an account in their page to be able to download the required [binary
    files](https://www.oracle.com/database/technologies/oracle-database-software-downloads.html).
    [Fake person generator](https://www.fakepersongenerator.com/) might come
    handy for this step.
* [Download the
    files](https://download.oracle.com/otn/linux/oracle19c/190000/LINUX.X64_193000_db_home.zip).

* After downloading the file we need to copy it to the folder referring to the oracle version in the cloned folder. In this case, 19.3.0:

    ```bash
    mv ~/Download/LINUX.X64_193000_db_home.zip ./docker-images/OracleDatabase/SingleInstance/dockerfiles/19.3.0/
    ```

* The next step is to build the image. You need at least 20G free in
    `/var/lib/docker`.

    ```bash
    ./docker-images/OracleDatabase/SingleInstance/dockerfiles/19.3.0/buildDockerImage.sh -v 19.3.0 -e
    ```

* Confirm that the image was created
    ```bash
    docker images

    REPOSITORY                                TAG           IMAGE ID       CREATED          SIZE
    oracle/database                           19.3.0-ee     d8be8934332d   53 minutes ago   6.54GB
    ```

* Run the database docker.
    ```bash
    docker run --name myOracle1930 \
     -p 127.0.0.1:1521:1521 \
     -p 127.0.0.1:5500:5500 \
     -e ORACLE_SID=ORCLCDB \
     -e ORACLE_PDB=ORCLPDB1 \
     -e ORACLE_PWD=root \
     -e INIT_SGA_SIZE=1024 \
     -e INIT_PGA_SIZE=1024 \
     -e ORACLE_CHARACTERSET=AL32UTF8 \
     oracle/database:19.3.0-ee
    ```
