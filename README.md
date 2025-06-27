# rp-expedia-recon

This repository contains the code for the DAGs as well as the custom code to ingest files, calculate audits, reconcile payments by transaction, and create reports for the full Expedia Reconciliation Process. This file describe the steps to setup the local development environment. The development env consists of the following docker containers: Airflow, MS SQL Server, sftp server and LocalStack which is used to simulate the AWS services such as S3, Secret Manager, etc.

## Prerequisites 

Install the following applications

* Docker desktop

* SQL Client such as Dbeaver (https://dbeaver.io/download/)

* awslocal and awscli

For Macbook, use homebrew to install awslocal and awscli by running the following commands:   

```brew  update```

```brew  install awscli```

```brew  install awscli-local```

## Bring up local containers 

* In the project directory, run the following command to build images for services:

```docker-compose build --no-cache > build_output.log 2>&1```

* Start all the services defined in docker-compose.yaml file:

```docker compose up -d```

* Verify all the services are up and running:

```docker ps -a```

This should bring up the following services: 

* an Apache Airflow service. The Web UI can be launched at: ```http://127.0.0.1:8090``` with credential ```airflow/airflow```.
* MS SQL Server.  It can be accessed with a SQL Client (such DBeaver)

```Host: localhost```

```Port: 1443```

```Database/Schema: master```

```Authentication: SQL Server Authentication```

```Username: SA```

```Password: WexAdmin1!```

* A sftp server. We can ssh to the sftp server: 

```sftp -P 2222 sftpuser@127.0.0.1```

using the password: ```password```

* A local aws service(LocalStack). 

## Local S3 operations 

* Create a bucket in LocalStack:

```awslocal s3 mb s3://my-test-bucket```

* Upload a test file to your local S3 bucket:

```echo "Hello from LocalStack S3!" > test_file.txt```

```awslocal s3 cp test_file.txt s3://my-test-bucket/test_file.txt```

* Verify the file is in your local S3 bucket:

```awslocal s3 ls s3://my-test-bucket/```

## Airflow connection setup 

Login to ```http://127.0.0.1:8090``` and  click Admin then connections. The follwoing connections should be added.

* MS SQL Server Connection:

```Connection ID: mssql_conn```

```Connection Type: mssql```

```Host: sql_server_test```

```Login: sa```

```Password:  WexAdmin1!```

```Port: 1433```

```Schema: master```

* AWS Connection

```Connection ID: aws_default```

```Connection Type: aws```

```Access Key Id: test```

```Secret Access Key: test```

```region_name:  us-east-1```

```endpoint_url: http://localstack:4566```

```Extra Fields JSON: { "region_name": "us-east-1", "endpoint_url": "http://localstack:4566"}```

## Rebuild

In case rebuild is needed, then run the following command to clean up: 

```docker compose down -v```

and then rerun the following command to build images for services:

```docker-compose build --no-cache > build_output.log 2>&1```

## Workaround

* If the http or sftp request got hung, restart the apiserver container or sftp container

```docker ps``` to find the container ID

```docker restart <containerId>``` to restart the containder.

* If sftp command got rejected, run the following commands to clear the local key and force to regenerate the key in the next request and then run sfto command

```ssh-keygen -R "[127.0.0.1]:2222"```
